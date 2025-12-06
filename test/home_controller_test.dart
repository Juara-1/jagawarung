import 'package:flutter_test/flutter_test.dart';

/// Helper function to format currency (extracted from DebtController for testing)
String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
}

/// Helper function to format date (extracted from DebtController for testing)
String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

void main() {
  group('Debt helper functions', () {
    test('formatCurrency formats rupiah with dot separator', () {
      expect(formatCurrency(9876543), 'Rp 9.876.543');
      expect(formatCurrency(50000), 'Rp 50.000');
    });

    test('formatDate returns dd/mm/yyyy', () {
      final date = DateTime(2025, 1, 2);
      expect(formatDate(date), '2/1/2025');
    });
  });
}

