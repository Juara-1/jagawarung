import 'package:jagawarung/app/data/models/transaction_model.dart';
import '../providers/real_transaction_provider.dart';
import '../models/debt_model.dart';


class DebtService {
  final RealTransactionProvider _provider = RealTransactionProvider();

  Future<TransactionModel> addDebt(TransactionModel debt) async {
    try {
      // Hutang pakai upsert=true untuk merge kalau ada yang sama
      return await _provider.createTransaction(debt, upsert: true);
    } catch (e) {
      throw Exception('Failed to add debt: $e');
    }
  }

  /// Voice-first debt recording via agent endpoint
  Future<VoiceAgentResult> addDebtViaAgent(String prompt) async {
    try {
      return await _provider.voiceAgentTransaction(
        type: TransactionType.debts,
        prompt: prompt,
      );
    } catch (e) {
      throw Exception('Failed to add debt via agent: $e');
    }
  }


  Future<List<TransactionModel>> getAllDebts() async {
    try {
      final allTransactions = await _provider.getTransactions(
        type: 'debts',
        orderBy: 'created_at',
        orderDirection: 'desc',
      );
      return allTransactions;
    } catch (e) {
      throw Exception('Failed to get debts: $e');
    }
  }


  Future<List<TransactionModel>> getDebtsByCustomer(String customerName) async {
    try {
      final normalizedName = customerName.trim().toLowerCase();
      
      // Get all debts then filter by customer name (backend doesn't support debtor_name filter yet)
      final allDebts = await getAllDebts();
      
      return allDebts.where((debt) {
        final debtorName = debt.customerName?.toLowerCase() ?? '';
        return debtorName.contains(normalizedName);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get debts by customer: $e');
    }
  }

 
  Future<double> getTotalDebtByCustomer(String customerName) async {
    try {
      final debts = await getDebtsByCustomer(customerName);
      final total = debts.fold<double>(
        0.0,
        (double sum, TransactionModel debt) => sum + debt.amount,
      );
      return total;
    } catch (e) {
      throw Exception('Failed to calculate total debt: $e');
    }
  }

  Future<DebtSummary> getDebtSummary(String customerName) async {
    try {
      final debts = await getDebtsByCustomer(customerName);
      final total = debts.fold(0.0, (sum, debt) => sum + debt.amount);

      return DebtSummary(
        customerName: customerName,
        totalDebt: total,
        debts: debts,
      );
    } catch (e) {
      throw Exception('Failed to get debt summary: $e');
    }
  }


  Future<void> deleteDebt(String debtId) async {
    try {
      await _provider.deleteTransaction(debtId);
    } catch (e) {
      throw Exception('Failed to delete debt: $e');
    }
  }

  Future<TransactionModel> updateDebt(TransactionModel debt) async {
    try {
      if (debt.id == null) {
        throw Exception('Debt ID is required for update');
      }
      await _provider.updateTransaction(debt.id!, debt);
      return debt;
    } catch (e) {
      throw Exception('Failed to update debt: $e');
    }
  }

  /// Pelunasan hutang
  /// Akan mengubah transaksi dari debts → earning
  Future<TransactionModel> repayDebt(String debtId) async {
    try {
      return await _provider.repayDebt(debtId);
    } catch (e) {
      throw Exception('Failed to repay debt: $e');
    }
  }
}
