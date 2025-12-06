import 'package:flutter_test/flutter_test.dart';

/// Helper function to format currency (extracted from DashboardController for testing)
String formatCurrency(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
}

void main() {
  group('Dashboard formatCurrency helper', () {
    test('formats rupiah with dot separator', () {
      expect(formatCurrency(1234567), 'Rp 1.234.567');
      expect(formatCurrency(1000), 'Rp 1.000');
      expect(formatCurrency(50000), 'Rp 50.000');
    });
  });
}

