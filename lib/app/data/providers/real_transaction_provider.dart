import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jagawarung/env.dart';
import '../models/transaction_model.dart';
import '../models/dashboard_model.dart';
import '../services/token_service.dart';
import '../../routes/app_routes.dart';

class RealTransactionProvider {
  final Dio _dio;
  final String baseUrl;

  RealTransactionProvider({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl ?? Environment.apiBaseUrl,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '${(baseUrl ?? Environment.apiBaseUrl)}/api',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    // Skip interceptors if custom Dio is injected (typically for testing)
    if (dio == null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid - redirect to login
            Get.snackbar(
              'Sesi Berakhir',
              'Silakan login kembali',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade100,
              duration: const Duration(seconds: 2),
            );
            
            // Clear tokens
            await TokenService.clearTokens();
            
            // Redirect to login (delay to show snackbar)
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.offAllNamed(AppRoutes.login);
            });
          }
          return handler.next(error);
        },
      ));

      // Removed logger for production
    }
  }

  Future<ParsedVoiceResult> parseVoice(String transcript) async {
    final lower = transcript.toLowerCase();

    if (lower.contains('jual') || lower.contains('masuk') || lower.contains('dapat') || lower.contains('terima')) {
      final amount = _extractAmount(transcript);
      return ParsedVoiceResult(
        intent: 'ADD_INCOME',
        nominal: amount,
        customerName: _extractProductName(transcript),
        message: 'Pemasukan sebesar Rp ${_formatNumber(amount)} akan dicatat',
      );
    }

    if (lower.contains('beli') || lower.contains('belanja') || lower.contains('keluar') || lower.contains('bayar')) {
      final amount = _extractAmount(transcript);
      return ParsedVoiceResult(
        intent: 'ADD_EXPENSE',
        nominal: amount,
        customerName: _extractProductName(transcript),
        message: 'Pengeluaran sebesar Rp ${_formatNumber(amount)} akan dicatat',
      );
    }

    if (lower.contains('utang') || lower.contains('hutang') || lower.contains('bon') || lower.contains('pinjam')) {
      final amount = _extractAmount(transcript);
      final name = _extractName(transcript);
      return ParsedVoiceResult(
        intent: 'ADD_DEBT',
        debtorName: name,
        nominal: amount,
        message: 'Utang $name sebesar Rp ${_formatNumber(amount)} akan dicatat',
      );
    }

    throw Exception('Perintah tidak dikenali. Coba: "Jual minyak 15 ribu" atau "Utang Budi 20 ribu"');
  }

 
  Future<VoiceAgentResult> voiceAgentTransaction({
    required TransactionType type,
    required String prompt,
  }) async {
    try {
      final response = await _dio.post(
        '/agent/transactions',
        data: {
          'prompt': prompt,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final actionResult = data?['action_result'];

        TransactionModel? tx;
        if (actionResult != null && actionResult['transaction'] != null) {
          tx = TransactionModel.fromJson(actionResult['transaction']);
        } else if (data?['transaction'] != null) {
          tx = TransactionModel.fromJson(data['transaction']);
        }

        final message = actionResult?['message'] ??
            data?['message'] ??
            response.data['message'] ??
            'Transaksi berhasil diproses';

        return VoiceAgentResult(
          message: message,
          transaction: tx,
          raw: data,
        );
      }

      throw Exception(response.data['message'] ?? 'Gagal memproses voice agent');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<TransactionModel> createTransaction(
    TransactionModel transaction, {
    bool upsert = false,
  }) async {
    try {

      final queryParams = <String, dynamic>{};
      if (upsert) {
        queryParams['upsert'] = 'true';
      }

      final response = await _dio.post(
        '/transactions',
        data: transaction.toJson(),
        queryParameters: queryParams,
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          return TransactionModel.fromJson(response.data['data']);
        }
      }

      throw Exception('Failed to create transaction');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int perPage = 100,
    String? note,
    String? type,
    DateTime? createdFrom,
    DateTime? createdTo,
    String orderBy = 'created_at',
    String orderDirection = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'order_by': orderBy,
        'order_direction': orderDirection,
      };

      if (note != null && note.isNotEmpty) {
        queryParams['note'] = note;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (createdFrom != null) {
        queryParams['created_from'] = createdFrom.toIso8601String();
      }
      if (createdTo != null) {
        queryParams['created_to'] = createdTo.toIso8601String();
      }


      final response = await _dio.get(
        '/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] as List;
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<DashboardSummary> getDashboardSummary({
    String timeRange = 'day',
  }) async {
    try {
     
      final summary = await getTransactionSummary(timeRange: timeRange);

  
      final recentTransactions = await getTransactions(
        perPage: 10,
        orderBy: 'created_at',
        orderDirection: 'desc',
      );


      return DashboardSummary(
        todayIncome: summary['total_earning'] ?? 0,
        todayExpense: summary['total_spending'] ?? 0,
        totalDebt: summary['total_debts'] ?? 0,
        transactionCount: recentTransactions.length,
      );
    } catch (e) {
      return DashboardSummary.empty();
    }
  }

  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    try {
      final response = await _dio.put(
        '/transactions/$id',
        data: transaction.toJson(),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to update transaction');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final response = await _dio.delete('/transactions/$id');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to delete transaction');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  
  Future<TransactionModel> repayDebt(String transactionId) async {
    try {

      final response = await _dio.post('/transactions/$transactionId/repay');


      if (response.statusCode == 200 && response.data['success'] == true) {
        return TransactionModel.fromJson(response.data['data']);
      }

      throw Exception('Failed to repay debt');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }


  Future<Map<String, double>> getTransactionSummary({
    String timeRange = 'day',
  }) async {
    try {

      final response = await _dio.get(
        '/transactions/summary',
        queryParameters: {'time_range': timeRange},
      );


      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'total_debts': (data['total_debts'] as num?)?.toDouble() ?? 0,
          'total_spending': (data['total_spending'] as num?)?.toDouble() ?? 0,
          'total_earning': (data['total_earning'] as num?)?.toDouble() ?? 0,
        };
      }

      return {
        'total_debts': 0,
        'total_spending': 0,
        'total_earning': 0,
      };
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server.';
    }

    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data['message'] ?? 'Terjadi kesalahan';

      if (statusCode == 400) {
        return 'Data tidak valid: $message';
      } else if (statusCode == 404) {
        return 'Data tidak ditemukan';
      } else if (statusCode == 500) {
        return 'Server error: $message';
      }

      return message;
    }

    return 'Terjadi kesalahan: ${error.message}';
  }

  double _extractAmount(String text) {
    final patterns = [
      RegExp(r'(\d+)\s*(?:ribu|rb)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:juta|jt)', caseSensitive: false),
      RegExp(r'(\d+\.?\d*)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final number = double.parse(match.group(1)!);
        if (text.toLowerCase().contains('ribu') || text.toLowerCase().contains('rb')) {
          return number * 1000;
        }
        if (text.toLowerCase().contains('juta') || text.toLowerCase().contains('jt')) {
          return number * 1000000;
        }
        return number;
      }
    }

    return 0;
  }

  String _extractName(String text) {
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      final word = words[i].toLowerCase();
      if (word == 'utang' || word == 'hutang' || word == 'bon' || word == 'pinjam') {
        if (i + 1 < words.length) {
          return words[i + 1];
        }
      }
    }
    return 'Pelanggan';
  }

  String _extractProductName(String text) {
    final cleanText = text
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll(RegExp(r'ribu|rb|juta|jt|rp|rupiah', caseSensitive: false), '')
        .trim();

    final words = cleanText.split(' ');
    if (words.length >= 2) {
      return words.sublist(1).join(' ');
    }

    return 'Produk';
  }

  String _formatNumber(double? amount) {
    if (amount == null) return '0';
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class VoiceAgentResult {
  final String message;
  final TransactionModel? transaction;
  final dynamic raw;

  VoiceAgentResult({
    required this.message,
    this.transaction,
    this.raw,
  });
}

