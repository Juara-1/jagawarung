import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jagawarung/app/data/models/transaction_model.dart';
import 'package:jagawarung/app/data/providers/real_transaction_provider.dart';

class _FakeAgentAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/agent/transactions') {
      final body = jsonEncode({
        'success': true,
        'message': 'Hutang untuk andi berhasil dicatat sebesar 100000',
        'data': {
          'action_result': {
            'action': 'upsert_debt',
            'message': 'Hutang untuk andi berhasil dicatat sebesar 100000',
            'transaction': {
              'id': 'tx-1',
              'nominal': 100000,
              'debtor_name': 'andi',
              'invoice_url': null,
              'invoice_data': null,
              'note': 'Utang andi',
              'created_at': '2025-12-06T10:54:37.200088+00:00',
              'updated_at': '2025-12-06T11:21:07.845016+00:00',
            },
          },
        },
      });

      return ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    throw Exception('Unexpected path: ${options.path}');
  }
}

void main() {
  group('RealTransactionProvider.parseVoice', () {
    final provider = RealTransactionProvider(baseUrl: 'https://fake');

    test('detects earning intent', () async {
      final result = await provider.parseVoice('jual kopi 15000');
      expect(result.intent, 'ADD_INCOME');
      expect(result.transactionType, TransactionType.earning);
    });

    test('detects spending intent', () async {
      final result = await provider.parseVoice('belanja beras 50000');
      expect(result.intent, 'ADD_EXPENSE');
      expect(result.transactionType, TransactionType.spending);
    });

    test('detects debt intent', () async {
      final result = await provider.parseVoice('hutang budi 20000');
      expect(result.intent, 'ADD_DEBT');
      expect(result.transactionType, TransactionType.debts);
    });
  });

  group('RealTransactionProvider.voiceAgentTransaction', () {
    test('returns transaction and message from agent', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://fake/api'));
      dio.httpClientAdapter = _FakeAgentAdapter();

      final provider = RealTransactionProvider(
        baseUrl: 'https://fake',
        dio: dio,
      );

      final result = await provider.voiceAgentTransaction(
        type: TransactionType.debts,
        prompt: 'andi seratus ribu',
      );

      expect(result.message, contains('berhasil dicatat'));
      expect(result.transaction, isNotNull);
      expect(result.transaction!.amount, 100000);
      expect(result.transaction!.customerName, 'andi');
      expect(result.transaction!.type, TransactionType.debts);
    });
  });
}


