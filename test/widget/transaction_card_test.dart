import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spend_arc/core/theme/app_theme.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/presentation/widgets/transaction_card.dart';

void main() {
  testWidgets('TransactionCard displays transaction title and category',
      (WidgetTester tester) async {
    final transaction = Transaction(
      id: 'test-1',
      title: 'Grocery Shopping',
      amount: 85.50,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime(2024, 1, 15),
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
      isSynced: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TransactionCard(
            transaction: transaction,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Grocery Shopping'), findsOneWidget);
    expect(find.textContaining('Food'), findsOneWidget);
  });

  testWidgets('TransactionCard shows income transaction',
      (WidgetTester tester) async {
    final transaction = Transaction(
      id: 'test-2',
      title: 'Salary Income',
      amount: 3000,
      type: TransactionType.income,
      categoryId: 'salary',
      date: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      isSynced: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TransactionCard(
            transaction: transaction,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Salary Income'), findsOneWidget);
  });

  testWidgets('TransactionCard calls onDelete callback when swiped',
      (WidgetTester tester) async {
    bool deleted = false;
    final transaction = Transaction(
      id: 'test-3',
      title: 'Delete Me',
      amount: 50,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime(2024, 1, 15),
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
      isSynced: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TransactionCard(
            transaction: transaction,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Delete Me'), findsOneWidget);

    await tester.timedDrag(
      find.text('Delete Me'),
      const Offset(-200, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(deleted, true);
  });
}
