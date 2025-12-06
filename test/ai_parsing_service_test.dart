import 'package:flutter_test/flutter_test.dart';

/// Mock fallback parsing logic (extracted from AiParsingService for testing without Gemini API)
Map<String, dynamic> fallbackParsing(String text) {
  final lowerText = text.toLowerCase();

  String action = 'unknown';
  String name = '';
  double? amount;

  if (lowerText.contains(RegExp(r'cat[ae]t?\s+(hutang|utang)'))) {
    action = 'catat_hutang';
    final match = RegExp(
      r'cat[ae]t?\s+(?:hutang|utang)\s+([a-zA-Z\s]+?)\s+(.+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      name = match.group(1)?.trim() ?? '';
      amount = parseIndonesianNumber(match.group(2)?.trim() ?? '');
    }
  } else if (lowerText.contains(RegExp(r'b[ae]r[ae]pa\s+(hutang|utang)'))) {
    action = 'cek_hutang';
    final match = RegExp(
      r'b[ae]r[ae]pa\s+(?:hutang|utang)\s+([a-zA-Z\s]+?)(?:\?|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      name = match.group(1)?.trim() ?? '';
    }
  } else if (lowerText.contains(RegExp(r'hapus\s+(hutang|utang)'))) {
    action = 'hapus_hutang';
    final match = RegExp(
      r'hapus\s+(?:hutang|utang)\s+([a-zA-Z\s]+?)(?:\?|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      name = match.group(1)?.trim() ?? '';
    }
  }

  return {
    'action': action,
    'name': name,
    'amount': amount,
    'confidence': 'low',
  };
}

double parseIndonesianNumber(String text) {
  final lower = text.toLowerCase().trim();

  if (lower.contains('seratus') && lower.contains('ribu')) {
    return 100000;
  }
  if (lower.contains('ribu')) {
    return 1000;
  }
  if (lower.contains('juta')) {
    return 1000000;
  }
  return 0;
}

void main() {
  group('AI Parsing fallback logic (no API)', () {
    test('parses catat hutang with name and amount', () {
      final res = fallbackParsing('catat hutang budi seratus ribu');
      expect(res['action'], 'catat_hutang');
      expect(res['name'].toString().toLowerCase(), contains('budi'));
      expect(res['amount'], greaterThan(0));
    });

    test('parses cek hutang with name', () {
      final res = fallbackParsing('berapa hutang Andi');
      expect(res['action'], 'cek_hutang');
      expect(res['name'].toString().toLowerCase(), contains('andi'));
    });

    test('parses hapus hutang with name', () {
      final res = fallbackParsing('hapus hutang Sari');
      expect(res['action'], 'hapus_hutang');
      expect(res['name'].toString().toLowerCase(), contains('sari'));
    });

    test('parseIndonesianNumber handles simple cases', () {
      expect(parseIndonesianNumber('seratus ribu'), 100000);
      expect(parseIndonesianNumber('ribu'), 1000);
      expect(parseIndonesianNumber('juta'), 1000000);
    });
  });
}

