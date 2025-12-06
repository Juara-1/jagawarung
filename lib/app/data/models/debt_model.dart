
import 'package:jagawarung/app/data/models/transaction_model.dart';

class DebtSummary {
  final String customerName;
  final double totalDebt;
  final List<TransactionModel> debts;

  DebtSummary({
    required this.customerName,
    required this.totalDebt,
    required this.debts,
  });
}
