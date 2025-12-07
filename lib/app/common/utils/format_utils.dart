import 'package:intl/intl.dart';

class FormatUtils {
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format number as currency with thousand separator
  /// Example: 1000000 -> "Rp 1.000.000"
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Format number with thousand separator only (no Rp prefix)
  /// Example: 1000000 -> "1.000.000"
  static String formatNumber(double number) {
    return NumberFormat.decimalPattern('id_ID').format(number);
  }

  /// Parse currency string to double
  /// Example: "Rp 1.000.000" or "1.000.000" -> 1000000.0
  static double parseCurrency(String value) {
    try {
      // Remove Rp, spaces, and thousand separators (.)
      final cleaned = value
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.') // Handle comma as decimal separator
          .trim();
      return double.tryParse(cleaned) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  static String formatDate(DateTime date, {bool padZero = true}) {
    if (padZero) {
      final d = date.toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }
}


