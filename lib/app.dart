import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_arc/core/di/injection_container.dart';
import 'package:spend_arc/core/theme/app_theme.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_bloc.dart';
import 'package:spend_arc/presentation/bloc/budget/budget_event.dart';
import 'package:spend_arc/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:spend_arc/presentation/bloc/sync/sync_bloc.dart';
import 'package:spend_arc/presentation/bloc/sync/sync_event.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:spend_arc/presentation/pages/dashboard_page.dart';

class SpendArcApp extends StatelessWidget {
  const SpendArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TransactionBloc>()),
        BlocProvider(
          create: (_) {
            final bloc = sl<BudgetBloc>();
            bloc.add(LoadBudget());
            return bloc;
          },
        ),
        BlocProvider(create: (_) => sl<DashboardBloc>()),
        BlocProvider(
          create: (_) {
            final bloc = sl<SyncBloc>();
            bloc.add(StartSync());
            return bloc;
          },
        ),
      ],
      child: MaterialApp(
        title: 'SpendArc',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const DashboardPage(),
      ),
    );
  }
}
