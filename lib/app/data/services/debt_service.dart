import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/debt_model.dart';


class DebtService {
  final _supabase = Supabase.instance.client;
  static const String _tableName = 'debts';


  Future<DebtModel> addDebt(DebtModel debt) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(debt.toJson())
          .select()
          .single();

      return DebtModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add debt: $e');
    }
  }


  Future<List<DebtModel>> getAllDebts() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get debts: $e');
    }
  }


  Future<List<DebtModel>> getDebtsByCustomer(String customerName) async {
    try {
      final normalizedName = customerName.trim();

      final response = await _supabase
          .from(_tableName)
          .select()
        
          .ilike('debtor_name', '%$normalizedName%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get debts by customer: $e');
    }
  }

 
  Future<double> getTotalDebtByCustomer(String customerName) async {
    try {
      final debts = await getDebtsByCustomer(customerName);
      final total = debts.fold<double>(
        0.0,
        (double sum, DebtModel debt) => sum + debt.amount,
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
      await _supabase.from(_tableName).delete().eq('id', debtId);
    } catch (e) {
      throw Exception('Failed to delete debt: $e');
    }
  }


  Future<DebtModel> updateDebt(DebtModel debt) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(debt.toJson())
          .eq('id', debt.id!)
          .select()
          .single();

      return DebtModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update debt: $e');
    }
  }
}
