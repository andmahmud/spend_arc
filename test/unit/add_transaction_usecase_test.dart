import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/domain/repositories/transaction_repository.dart';
import 'package:spend_arc/domain/usecases/transactions/add_transaction.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late AddTransaction useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = AddTransaction(repository: mockRepository);
  });

  final tTransaction = Transaction(
    id: '1',
    title: 'Test Transaction',
    amount: 99.99,
    type: TransactionType.expense,
    categoryId: 'food',
    date: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test('should add transaction and return it', () async {
    when(() => mockRepository.addTransaction(tTransaction))
        .thenAnswer((_) async => right(tTransaction));

    final result = await useCase(tTransaction);

    expect(result.isRight(), true);
    expect(result.asRight(), tTransaction);
  });

  test('should return failure when repository fails', () async {
    when(() => mockRepository.addTransaction(tTransaction)).thenAnswer(
      (_) async => left(CacheFailure(message: 'Error')),
    );

    final result = await useCase(tTransaction);

    expect(result.isLeft(), true);
    expect(result.asLeft().message, 'Error');
  });
}
