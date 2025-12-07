import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../env.dart';


class ExpenseOcrService {
  static const String _baseUrl = 'https://api.kolosal.ai';
  
  late final Dio _dio;

  ExpenseOcrService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer ${Environment.kolosalApiKey}',
      },
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    // Removed logger for production
  }


  Future<ExpenseOcrResult> scanReceipt(File imageFile) async {
    try {

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
          contentType: MediaType('image', 'jpeg'),
        ),
        'invoice': 'true',      // Enable invoice mode
        'language': 'id',       // Indonesian language
      });


      final response = await _dio.post(
        '/ocr/form',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseOcrResponse(response.data);
      }

      throw Exception('OCR failed with status: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Gagal memproses gambar: $e');
    }
  }


  ExpenseOcrResult _parseOcrResponse(dynamic data) {
    try {
 
      final extractedData = data['data'] ?? data;
      
      double totalAmount = 0;
      String storeName = '';
      List<String> items = [];

      final possibleTotalFields = [
        'total',
        'grand_total',
        'total_amount',
        'amount',
        'jumlah',
        'jumlah_total',
      ];

      for (var field in possibleTotalFields) {
        if (extractedData[field] != null) {
          totalAmount = _parseAmount(extractedData[field].toString());
          if (totalAmount > 0) break;
        }
      }

      final storeFields = ['store_name', 'merchant', 'nama_toko', 'toko'];
      for (var field in storeFields) {
        if (extractedData[field] != null) {
          storeName = extractedData[field].toString();
          if (storeName.isNotEmpty) break;
        }
      }

  
      if (extractedData['items'] != null && extractedData['items'] is List) {
        for (var item in extractedData['items']) {
          if (item is Map && item['name'] != null) {
            items.add(item['name'].toString());
          }
        }
      }

    
      if (totalAmount == 0 && extractedData['items'] != null) {
        for (var item in extractedData['items']) {
          if (item is Map && item['price'] != null) {
            totalAmount += _parseAmount(item['price'].toString());
          }
        }
      }


      return ExpenseOcrResult(
        totalAmount: totalAmount,
        storeName: storeName.isEmpty ? 'Toko' : storeName,
        items: items,
        rawData: extractedData,
      );
    } catch (e) {
      throw Exception('Gagal membaca struk: $e');
    }
  }


  double _parseAmount(String value) {
    try {
     
      String cleaned = value
          .replaceAll(RegExp(r'[Rp\s.]'), '')
          .replaceAll(',', '.');
      
      return double.tryParse(cleaned) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Coba lagi.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server OCR.';
    }

    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      
      if (statusCode == 401) {
        return 'API key tidak valid. Periksa KOLOSAL_API_KEY.';
      } else if (statusCode == 400) {
        return 'Format gambar tidak valid.';
      } else if (statusCode == 500) {
        return 'Server OCR error. Coba lagi.';
      }

      return error.response?.data['message'] ?? 'OCR gagal';
    }

    return 'Terjadi kesalahan: ${error.message}';
  }
}


class ExpenseOcrResult {
  final double totalAmount;
  final String storeName;
  final List<String> items;
  final Map<String, dynamic> rawData;

  ExpenseOcrResult({
    required this.totalAmount,
    required this.storeName,
    required this.items,
    required this.rawData,
  });

  String get formattedAmount {
    return 'Rp ${totalAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String get summary {
    if (items.isEmpty) {
      return '$storeName - $formattedAmount';
    }
    return '$storeName - ${items.length} items - $formattedAmount';
  }
}

