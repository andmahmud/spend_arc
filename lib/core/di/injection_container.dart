import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:spend_arc/core/network/network_info.dart';
import 'package:spend_arc/data/datasources/local/transaction_local_datasource.dart';
import 'package:spend_arc/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:spend_arc/data/repositories/budget_repository_impl.dart';
import 'package:spend_arc/data/repositories/transaction_repository_impl.dart';
import 'package:spend_arc/domain/repositories/budget_repository.dart';
import 'package:spend_arc/domain/repositories/transaction_repository.dart';
import 'package:spend_arc/domain/usecases/budgets/get_budget.dart';
import 'package:spend_arc/domain/usecases/budgets/update_budget.dart';
import 'package:spend_arc/domain/usecases/transactions/add_transaction.dart';
import 'package:spend_arc/domain/usecases/transactions/delete_transaction.dart';
import 'package:spend_arc/domain/usecases/transactions/get_transactions.dart';
import 'package:spend_arc/domain/usecases/transactions/sync_transactions.dart';
import 'package:spend_arc/domain/usecases/transactions/update_transaction.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_bloc.dart';
import 'package:spend_arc/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:spend_arc/presentation/bloc/sync/sync_bloc.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  await _initDataSources();
  await _initRepositories();
  await _initUseCases();
  await _initBlocs();
}

Future<void> _initCore() async {
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );
}

Future<void> _initDataSources() async {
  final localDataSource = TransactionLocalDataSourceImpl();
  sl.registerLazySingleton<TransactionLocalDataSource>(() => localDataSource);

  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(),
  );
}

Future<void> _initRepositories() async {
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      budgetRepository: sl(),
    ),
  );

  sl.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl());
}

Future<void> _initUseCases() async {
  sl.registerLazySingleton(() => AddTransaction(repository: sl()));
  sl.registerLazySingleton(() => UpdateTransaction(repository: sl()));
  sl.registerLazySingleton(() => DeleteTransaction(repository: sl()));
  sl.registerLazySingleton(() => GetTransactions(repository: sl()));
  sl.registerLazySingleton(() => GetTransactionsByMonth(repository: sl()));
  sl.registerLazySingleton(() => SyncTransactions(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentBudget(repository: sl()));
  sl.registerLazySingleton(() => AdjustSpending(repository: sl()));
  sl.registerLazySingleton(() => UpdateBudget(repository: sl()));
}

Future<void> _initBlocs() async {
  sl.registerFactory(
    () => TransactionBloc(
      addTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
      getTransactions: sl(),
      syncTransactions: sl(),
    ),
  );

  sl.registerFactory(
    () => BudgetBloc(
      getCurrentBudget: sl(),
      adjustSpending: sl(),
      updateBudget: sl(),
    ),
  );

  sl.registerFactory(
    () => DashboardBloc(
      getTransactions: sl(),
      getCurrentBudget: sl(),
      getTransactionsByMonth: sl(),
    ),
  );

  sl.registerFactory(() => SyncBloc(syncTransactions: sl(), networkInfo: sl()));
}

Future<void> resetDependencies() async {
  await sl.reset();
}
