import 'package:flutter_test/flutter_test.dart';
import 'package:jagawarung/app/data/models/transaction_model.dart';
import 'package:jagawarung/app/data/providers/real_transaction_provider.dart';
import 'package:jagawarung/app/data/services/debt_service.dart';

class _FakeDebtProvider extends RealTransactionProvider {
  _FakeDebtProvider() : super(baseUrl: 'https://fake', dio: null);

  List<TransactionModel> stubDebts = [];
  TransactionModel? stubRepayResult;
  VoiceAgentResult? stubAgentResult;

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction,
      {bool upsert = false}) async {
    stubDebts.add(transaction);
    return transaction;
  }

  @override
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
    // Return only debts if requested
    if (type == 'debts') {
      return stubDebts.where((d) => d.type == TransactionType.debts).toList();
    }
    return stubDebts;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    stubDebts = stubDebts.where((d) => d.id != id).toList();
  }

  @override
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    stubDebts = stubDebts.map((d) => d.id == id ? transaction : d).toList();
  }

  @override
  Future<TransactionModel> repayDebt(String transactionId) async {
    if (stubRepayResult != null) return stubRepayResult!;
    throw Exception('no repay stub');
  }

  @override
  Future<VoiceAgentResult> voiceAgentTransaction({
    required TransactionType type,
    required String prompt,
  }) async {
    if (stubAgentResult != null) return stubAgentResult!;
    throw Exception('no agent stub');
  }
}

void main() {
  group('DebtService', () {
    late _FakeDebtProvider provider;
    late DebtService service;

    setUp(() {
      provider = _FakeDebtProvider();
      service = DebtService(provider: provider);
    });

    test('addDebt uses provider and stores debt', () async {
      final debt = TransactionModel(
        id: '1',
        type: TransactionType.debts,
        amount: 10000,
        customerName: 'Andi',
        description: 'Utang Andi',
        createdAt: DateTime.now(),
      );

      final result = await service.addDebt(debt);
      expect(result.amount, 10000);
      expect(provider.stubDebts.length, 1);
    });

    test('addDebtViaAgent returns agent result', () async {
      provider.stubAgentResult = VoiceAgentResult(
        message: 'OK',
        transaction: TransactionModel(
          id: '2',
          type: TransactionType.debts,
          amount: 20000,
          customerName: 'Budi',
          description: 'Utang Budi',
          createdAt: DateTime.now(),
        ),
        raw: {},
      );

      final res = await service.addDebtViaAgent('budi dua puluh ribu');
      expect(res.message, 'OK');
      expect(res.transaction?.customerName, 'Budi');
    });

    test('getDebtSummary sums only matching customer', () async {
      provider.stubDebts = [
        TransactionModel(
          id: 'd1',
          type: TransactionType.debts,
          amount: 1000,
          customerName: 'Ana',
          description: 'Utang',
          createdAt: DateTime.now(),
        ),
        TransactionModel(
          id: 'd2',
          type: TransactionType.debts,
          amount: 2000,
          customerName: 'ana maria',
          description: 'Utang',
          createdAt: DateTime.now(),
        ),
        TransactionModel(
          id: 'd3',
          type: TransactionType.earning,
          amount: 9999,
          customerName: 'Ana',
          description: 'Income',
          createdAt: DateTime.now(),
        ),
      ];

      final summary = await service.getDebtSummary('ana');
      expect(summary.totalDebt, 3000);
      expect(summary.debts.length, 2);
    });

    test('repayDebt delegates to provider', () async {
      provider.stubRepayResult = TransactionModel(
        id: 'd4',
        type: TransactionType.earning,
        amount: 5000,
        customerName: null,
        description: 'Lunas',
        createdAt: DateTime.now(),
      );

      final res = await service.repayDebt('d4');
      expect(res.type, TransactionType.earning);
      expect(res.customerName, isNull);
    });
  });
}


