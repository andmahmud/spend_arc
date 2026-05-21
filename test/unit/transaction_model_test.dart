import 'package:flutter_test/flutter_test.dart';
import 'package:spend_arc/data/models/transaction_model.dart';
import 'package:spend_arc/domain/entities/transaction.dart';

void main() {
  group('TransactionModel', () {
    final testTransaction = Transaction(
      id: 'test-1',
      title: 'Lunch',
      amount: 25.50,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime(2024, 1, 15),
      note: 'Restaurant',
      createdAt: DateTime(2024, 1, 15, 12, 0),
      updatedAt: DateTime(2024, 1, 15, 12, 0),
      isSynced: false,
    );

    test('should convert to Map and back', () {
      final model = TransactionModel.fromEntity(testTransaction);

      final map = model.toMap();
      final restored = TransactionModel.fromMap(map);

      expect(restored.id, testTransaction.id);
      expect(restored.title, testTransaction.title);
      expect(restored.amount, testTransaction.amount);
      expect(restored.type, testTransaction.type);
      expect(restored.categoryId, testTransaction.categoryId);
      expect(restored.note, testTransaction.note);
      expect(restored.isSynced, testTransaction.isSynced);
    });

    test('should convert to entity and back', () {
      final model = TransactionModel.fromEntity(testTransaction);

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.title, model.title);
      expect(entity.amount, model.amount);
      expect(entity.type, model.type);
      expect(entity.categoryId, model.categoryId);
      expect(entity.note, model.note);
    });

    test('should handle null note', () {
      final tx = Transaction(
        id: 'test-2',
        title: 'Test',
        amount: 10,
        type: TransactionType.income,
        categoryId: 'salary',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = TransactionModel.fromEntity(tx);
      final map = model.toMap();
      final restored = TransactionModel.fromMap(map);

      expect(restored.note, isNull);
      expect(restored.title, 'Test');
    });

    test('should handle income type correctly', () {
      final tx = Transaction(
        id: 'test-3',
        title: 'Salary',
        amount: 5000,
        type: TransactionType.income,
        categoryId: 'salary',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = TransactionModel.fromEntity(tx);
      final map = model.toMap();

      expect(map['type'], 'income');
    });

    test('should handle expense type correctly', () {
      final tx = Transaction(
        id: 'test-4',
        title: 'Groceries',
        amount: 75,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final model = TransactionModel.fromEntity(tx);
      final map = model.toMap();

      expect(map['type'], 'expense');
    });
  });
}
