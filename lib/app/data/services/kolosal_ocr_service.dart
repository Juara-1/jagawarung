import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../env.dart';
import '../models/ocr_models.dart';

/// Kolosal AI OCR Service
/// Service untuk scan invoice menggunakan Kolosal AI
class KolosalOcrService {
  static const String _baseUrl = 'https://api.kolosal.ai';
  
  // 🔧 MOCK_MODE: Set true untuk testing tanpa API key
  // Set false saat sudah punya API key yang valid
  static const bool MOCK_MODE = false;
  
  late final Dio _dio;

  KolosalOcrService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': Environment.kolosalApiKey,
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// Scan invoice menggunakan OCR
  /// Menggunakan endpoint /ocr/form (multipart/form-data)
  Future<OcrInvoiceResponse> scanInvoice(File imageFile) async {
    // 🧪 MOCK MODE: Return dummy data untuk testing
    if (MOCK_MODE) {
      print('🧪 MOCK MODE: Using dummy OCR data');
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      return _getMockOcrResponse();
    }
    
    try {
      // Prepare form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
        'invoice': 'true',    // WAJIB: Detect sebagai invoice
        'auto_fix': 'true',   // Auto fix rotasi gambar
      });

      print('📸 Uploading image to Kolosal AI...');
      print('📁 File: ${imageFile.path}');
      print('📏 Size: ${await imageFile.length()} bytes');

      // Send request
      final response = await _dio.post(
        '/ocr/form',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      print('✅ OCR Response received');
      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse response
        final ocrResult = _parseOcrResponse(response.data);
        
        print('🎯 OCR Results:');
        print('   Supplier: ${ocrResult.supplierName}');
        print('   Invoice: ${ocrResult.invoiceNumber}');
        print('   Items: ${ocrResult.items.length}');
        print('   Total: ${ocrResult.totalAmount}');
        
        return ocrResult;
      } else {
        throw Exception('OCR failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.type}');
      print('❌ Message: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Koneksi timeout. Coba lagi.');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Error dari server: ${e.response?.statusCode}');
      } else {
        throw Exception('Gagal koneksi ke server OCR');
      }
    } catch (e) {
      print('❌ OCR Error: $e');
      throw Exception('Gagal memproses gambar: $e');
    }
  }

  /// Parse OCR response dari Kolosal AI
  OcrInvoiceResponse _parseOcrResponse(dynamic data) {
    try {
      // Kolosal AI bisa return berbagai format
      // Kita handle multiple kemungkinan struktur
      
      if (data is Map<String, dynamic>) {
        // Check for common response structures
        if (data.containsKey('results')) {
          return OcrInvoiceResponse.fromJson(data);
        } else if (data.containsKey('data')) {
          return OcrInvoiceResponse.fromJson(data['data']);
        } else {
          return OcrInvoiceResponse.fromJson(data);
        }
      }
      
      throw Exception('Invalid OCR response format');
    } catch (e) {
      print('❌ Parse Error: $e');
      print('📄 Raw data: $data');
      throw Exception('Gagal parse hasil OCR: $e');
    }
  }

  /// Extract items dari raw OCR text jika API tidak return structured data
  /// Fallback parsing
  List<OcrInvoiceItem> _extractItemsFromText(String text) {
    List<OcrInvoiceItem> items = [];
    
    // Simple regex pattern untuk detect item dengan harga
    // Format umum: "Nama Produk  qty  harga"
    final patterns = [
      RegExp(r'(.+?)\s+(\d+)\s+(?:Rp\.?\s*)?(\d+\.?\d*)(?:\.000)?', caseSensitive: false),
      RegExp(r'(.+?)\s+x\s*(\d+)\s+(?:Rp\.?\s*)?(\d+\.?\d*)', caseSensitive: false),
    ];

    final lines = text.split('\n');
    
    for (var line in lines) {
      for (var pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            final name = match.group(1)?.trim() ?? '';
            final qty = int.tryParse(match.group(2) ?? '1') ?? 1;
            final price = double.tryParse(match.group(3) ?? '0') ?? 0.0;
            
            if (name.isNotEmpty && price > 0) {
              items.add(OcrInvoiceItem(
                name: name,
                quantity: qty,
                price: price,
                total: price * qty,
              ));
            }
          } catch (e) {
            print('⚠️ Failed to parse line: $line');
          }
        }
      }
    }
    
    return items;
  }

  /// Test connection ke Kolosal API
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  /// Mock OCR Response untuk testing  tanpa API
  OcrInvoiceResponse _getMockOcrResponse() {
    return OcrInvoiceResponse(
      supplierName: 'Toko Sumber Rezeki',
      invoiceNumber: 'INV/2024/12/001',
      invoiceDate: DateTime.now(),
      totalAmount: 225000,
      items: [
        OcrInvoiceItem(
          name: 'Indomie Goreng',
          quantity: 10,
          price: 2500,
          total: 25000,
        ),
        OcrInvoiceItem(
          name: 'Aqua 600ml',
          quantity: 20,
          price: 3000,
          total: 60000,
        ),
        OcrInvoiceItem(
          name: 'Minyak Sania 2L',
          quantity: 5,
          price: 28000,
          total: 140000,
        ),
      ],
      rawText: '''
      TOKO SUMBER REZEKI
      Jl. Merdeka No. 123
      
      INV/2024/12/001
      Tanggal: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
      
      Indomie Goreng    10 x 2.500   = 25.000
      Aqua 600ml        20 x 3.000   = 60.000
      Minyak Sania 2L    5 x 28.000  = 140.000
      
      TOTAL: Rp 225.000
      ''',
    );
  }
}
