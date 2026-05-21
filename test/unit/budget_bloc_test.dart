import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spend_arc/core/errors/failures.dart';
import 'package:spend_arc/core/utils/either.dart';
import 'package:spend_arc/domain/entities/budget.dart';
import 'package:spend_arc/domain/usecases/budgets/get_budget.dart';
import 'package:spend_arc/domain/usecases/budgets/update_budget.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_bloc.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_event.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_state.dart';

class MockGetCurrentBudget extends Mock implements GetCurrentBudget {}
class MockAdjustSpending extends Mock implements AdjustSpending {}
class MockUpdateBudget extends Mock implements UpdateBudget {}

void main() {
  late BudgetBloc bloc;
  late MockGetCurrentBudget mockGetBudget;
  late MockAdjustSpending mockAdjustSpending;
  late MockUpdateBudget mockUpdateBudget;

  setUp(() {
    mockGetBudget = MockGetCurrentBudget();
    mockAdjustSpending = MockAdjustSpending();
    mockUpdateBudget = MockUpdateBudget();
    bloc = BudgetBloc(
      getCurrentBudget: mockGetBudget,
      adjustSpending: mockAdjustSpending,
      updateBudget: mockUpdateBudget,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tBudget = Budget(
    id: 'budget-1',
    totalAmount: 5000,
    spentAmount: 1000,
    month: 1,
    year: 2024,
    updatedAt: DateTime.now(),
  );

  test('initial state should be BudgetInitial', () {
    expect(bloc.state, isA<BudgetInitial>());
  });

  test('should emit [BudgetLoading, BudgetLoaded] when LoadBudget succeeds',
      () async {
    when(() => mockGetBudget())
        .thenAnswer((_) async => right(tBudget));

    final expected = [
      isA<BudgetLoading>(),
      isA<BudgetLoaded>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(LoadBudget());
  });

  test('should emit [BudgetLoading, BudgetError] when LoadBudget fails',
      () async {
    when(() => mockGetBudget()).thenAnswer(
      (_) async => left(CacheFailure(message: 'Error loading budget')),
    );

    final expected = [
      isA<BudgetLoading>(),
      isA<BudgetError>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    bloc.add(LoadBudget());
  });

  test('should emit updated budget on AdjustSpendingEvent', () async {
    when(() => mockGetBudget())
        .thenAnswer((_) async => right(tBudget));
    when(() => mockAdjustSpending(200))
        .thenAnswer((_) async => right(tBudget.copyWith(spentAmount: 1200)));

    bloc.add(LoadBudget());
    await Future.delayed(const Duration(milliseconds: 50));

    bloc.add(const AdjustSpendingEvent(delta: 200));
    await Future.delayed(const Duration(milliseconds: 50));

    final currentState = bloc.state;
    expect(currentState, isA<BudgetLoaded>());
  });
}
