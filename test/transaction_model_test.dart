import 'package:flutter_test/flutter_test.dart';
import 'package:jagawarung/app/data/models/transaction_model.dart';

void main() {
  group('TransactionModel.toJson', () {
    test('should include debtor_name only for debts', () {
      final debt = TransactionModel(
        type: TransactionType.debts,
        amount: 10000,
        customerName: 'Andi',
        description: 'Utang Andi',
        createdAt: DateTime.parse('2025-12-06T02:08:31.38049Z'),
      );

      final json = debt.toJson();
      expect(json['debtor_name'], 'Andi');
      expect(json['type'], 'debts');
    });

    test('should omit debtor_name for earning/spending', () {
      final tx = TransactionModel(
        type: TransactionType.spending,
        amount: 5000,
        customerName: 'Budi',
        description: 'Belanja',
        createdAt: DateTime.now(),
      );

      final json = tx.toJson();
      expect(json.containsKey('debtor_name'), isFalse);
      expect(json['type'], 'spending');
    });
  });

  group('TransactionModel.fromJson type inference', () {
    test('infers debts from note keyword', () {
      final tx = TransactionModel.fromJson({
        'id': '1',
        'nominal': 1000,
        'debtor_name': 'Sari',
        'note': 'Utang Sari',
        'created_at': '2025-12-06T02:08:31.38049Z',
      });
      expect(tx.type, TransactionType.debts);
    });

    test('infers spending from note keyword', () {
      final tx = TransactionModel.fromJson({
        'id': '2',
        'nominal': 2000,
        'note': 'Belanja harian',
        'created_at': '2025-12-06T02:08:31.38049Z',
      });
      expect(tx.type, TransactionType.spending);
    });

    test('defaults to earning otherwise', () {
      final tx = TransactionModel.fromJson({
        'id': '3',
        'nominal': 3000,
        'note': 'Pemasukan lain',
        'created_at': '2025-12-06T02:08:31.38049Z',
      });
      expect(tx.type, TransactionType.earning);
    });
  });
}


