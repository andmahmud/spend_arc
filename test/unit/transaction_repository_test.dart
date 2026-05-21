import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spend_arc/core/errors/exceptions.dart';
import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/network/network_info.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/data/datasources/local/transaction_local_datasource.dart';
import 'package:spend_arc/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:spend_arc/data/models/transaction_model.dart';
import 'package:spend_arc/data/repositories/transaction_repository_impl.dart';
import 'package:spend_arc/domain/entities/budget.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/domain/repositories/budget_repository.dart';

class MockLocalDataSource extends Mock implements TransactionLocalDataSource {}
class MockRemoteDataSource extends Mock implements TransactionRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late TransactionRepositoryImpl repository;
  late MockLocalDataSource mockLocal;
  late MockRemoteDataSource mockRemote;
  late MockNetworkInfo mockNetworkInfo;
  late MockBudgetRepository mockBudget;

  setUpAll(() {
    registerFallbackValue(TransactionModel(
      id: 'fallback',
      title: 'fallback',
      amount: 0,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    registerFallbackValue(0.0);
  });

  setUp(() {
    mockLocal = MockLocalDataSource();
    mockRemote = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockBudget = MockBudgetRepository();
    repository = TransactionRepositoryImpl(
      localDataSource: mockLocal,
      remoteDataSource: mockRemote,
      networkInfo: mockNetworkInfo,
      budgetRepository: mockBudget,
    );
    when(() => mockBudget.adjustSpending(any()))
        .thenAnswer((_) async => right(Budget(
          id: 'budget',
          totalAmount: 1000,
          spentAmount: 50,
          month: DateTime.now().month,
          year: DateTime.now().year,
          updatedAt: DateTime.now(),
        )));
  });

  group('getTransactions', () {
    final tModels = [
      TransactionModel(
        id: '1',
        title: 'Test',
        amount: 100,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('should return transactions from local data source', () async {
      when(() => mockLocal.getTransactions()).thenAnswer((_) async => tModels);

      final result = await repository.getTransactions();

      expect(result.isRight(), true);
      expect(result.asRight().length, 1);
      expect(result.asRight().first.id, '1');
    });

    test('should return CacheFailure when local data source throws', () async {
      when(() => mockLocal.getTransactions())
          .thenThrow(CacheException(message: 'Cache error'));

      final result = await repository.getTransactions();

      expect(result.isLeft(), true);
      expect(result.asLeft(), isA<CacheFailure>());
    });
  });

  group('addTransaction', () {
    final tTransaction = Transaction(
      id: '1',
      title: 'New',
      amount: 50,
      type: TransactionType.expense,
      categoryId: 'food',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should add transaction locally and return it', () async {
      when(() => mockLocal.addTransaction(any()))
          .thenAnswer((invocation) async {
        final model = invocation.positionalArguments[0] as TransactionModel;
        return model;
      });
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.addTransaction(tTransaction);

      expect(result.isRight(), true);
      expect(result.asRight().id, '1');
      expect(result.asRight().title, 'New');
    });

    test('should return CacheFailure when local add fails', () async {
      when(() => mockLocal.addTransaction(any()))
          .thenThrow(CacheException(message: 'Failed to add'));

      final result = await repository.addTransaction(tTransaction);

      expect(result.isLeft(), true);
      expect(result.asLeft().message, contains('Failed to add'));
    });
  });

  group('deleteTransaction', () {
    test('should delete transaction from local data source', () async {
      when(() => mockLocal.getTransactionById('1'))
          .thenAnswer((_) async => TransactionModel(
            id: '1', title: 'Test', amount: 50,
            type: TransactionType.expense, categoryId: 'food',
            date: DateTime.now(), createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      when(() => mockLocal.deleteTransaction('1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteTransaction('1');

      expect(result.isRight(), true);
    });

    test('should return CacheFailure when local delete fails', () async {
      when(() => mockLocal.getTransactionById('1'))
          .thenAnswer((_) async => TransactionModel(
            id: '1', title: 'Test', amount: 50,
            type: TransactionType.expense, categoryId: 'food',
            date: DateTime.now(), createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      when(() => mockLocal.deleteTransaction('1'))
          .thenThrow(CacheException(message: 'Delete failed'));

      final result = await repository.deleteTransaction('1');

      expect(result.isLeft(), true);
    });
  });
}
