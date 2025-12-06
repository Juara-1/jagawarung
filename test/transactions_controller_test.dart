import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jagawarung/app/data/models/transaction_model.dart';

/// Helper functions extracted from TransactionsController for testing

String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String typeLabel(TransactionType type) {
  switch (type) {
    case TransactionType.earning:
      return 'Pemasukan';
    case TransactionType.spending:
      return 'Pengeluaran';
    case TransactionType.debts:
      return 'Utang';
  }
}

Color typeColor(TransactionType type) {
  switch (type) {
    case TransactionType.earning:
      return Colors.green;
    case TransactionType.spending:
      return Colors.red;
    case TransactionType.debts:
      return Colors.orange;
  }
}

void main() {
  group('Transaction helper functions', () {
    test('formatCurrency formats with thousand separator', () {
      expect(formatCurrency(15000), 'Rp 15.000');
      expect(formatCurrency(1234567), 'Rp 1.234.567');
    });

    test('formatDate returns dd/mm/yyyy', () {
      final date = DateTime(2025, 12, 6);
      expect(formatDate(date), '06/12/2025');
    });

    test('typeLabel returns localized labels', () {
      expect(typeLabel(TransactionType.earning), 'Pemasukan');
      expect(typeLabel(TransactionType.spending), 'Pengeluaran');
      expect(typeLabel(TransactionType.debts), 'Utang');
    });

    test('typeColor returns correct color', () {
      expect(typeColor(TransactionType.earning), Colors.green);
      expect(typeColor(TransactionType.spending), Colors.red);
      expect(typeColor(TransactionType.debts), Colors.orange);
    });
  });
}

