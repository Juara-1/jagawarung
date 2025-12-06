import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';


class TransactionTypeUtils {
  static String getLabel(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return 'Pemasukan';
      case TransactionType.spending:
        return 'Pengeluaran';
      case TransactionType.debts:
        return 'Utang';
    }
  }

  static Color getColor(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return Colors.green;
      case TransactionType.spending:
        return Colors.red;
      case TransactionType.debts:
        return Colors.orange;
    }
  }

  static IconData getIcon(TransactionType type) {
    switch (type) {
      case TransactionType.earning:
        return Icons.arrow_upward_rounded;
      case TransactionType.spending:
        return Icons.arrow_downward_rounded;
      case TransactionType.debts:
        return Icons.receipt_long_rounded;
    }
  }

  static String getChipLabel(String typeValue) {
    switch (typeValue) {
      case 'earning':
        return 'Pemasukan';
      case 'spending':
        return 'Pengeluaran';
      case 'debts':
        return 'Utang';
      default:
        return 'Semua';
    }
  }
}


