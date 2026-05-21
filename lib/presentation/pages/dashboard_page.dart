import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spend_arc/core/theme/app_theme.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:spend_arc/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:spend_arc/presentation/bloc/dashboard/dashboard_state.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_event.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_state.dart';
import 'package:spend_arc/presentation/pages/transactions_page.dart';
import 'package:spend_arc/presentation/widgets/arc_meter.dart';
import 'package:spend_arc/presentation/widgets/line_chart.dart';
import 'package:spend_arc/presentation/widgets/transaction_card.dart';
import 'package:spend_arc/presentation/pages/add_transaction_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendArc'),
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  context.read<DashboardBloc>().add(RefreshDashboard());
                  context.read<TransactionBloc>().add(LoadTransactions());
                },
              );
            },
          ),
        ],
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess || state is TransactionLoaded) {
            context.read<DashboardBloc>().add(RefreshDashboard());
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is DashboardError) {
            return _buildErrorState(state.message);
          }

          if (state is DashboardLoaded) {
            return _buildDashboard(state.data);
          }

          return const SizedBox.shrink();
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(DashboardData data) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    final List<double> spendingByDay = _calculateSpendingByDay(data.monthlyTransactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBudgetSection(data, currencyFormat),
          const SizedBox(height: 24),
          _buildStatsRow(data, currencyFormat),
          const SizedBox(height: 24),
          if (spendingByDay.isNotEmpty) _buildChartSection(spendingByDay),
          if (spendingByDay.isNotEmpty) const SizedBox(height: 24),
          _buildRecentTransactions(data.recentTransactions),
        ],
      ),
    );
  }

  List<double> _calculateSpendingByDay(List<Transaction> transactions) {
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return [];

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dailySpending = List<double>.filled(daysInMonth, 0);

    for (final tx in expenses) {
      final day = tx.date.day - 1;
      if (day >= 0 && day < daysInMonth) {
        dailySpending[day] += tx.amount;
      }
    }

    return dailySpending;
  }

  Widget _buildBudgetSection(DashboardData data, NumberFormat format) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.budget.usagePercentage > 0.8
                        ? AppColors.error.withValues(alpha: 0.15)
                        : AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(data.budget.usagePercentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: data.budget.usagePercentage > 0.8
                          ? AppColors.error
                          : AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ArcMeter(
              percentage: data.budget.usagePercentage,
              totalAmount: data.budget.totalAmount,
              spentAmount: data.budget.spentAmount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(DashboardData data, NumberFormat format) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Income',
            amount: format.format(data.totalIncome),
            color: AppColors.income,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Total Expenses',
            amount: format.format(data.totalExpense),
            color: AppColors.expense,
            icon: Icons.trending_down_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Balance',
            amount: format.format(data.balance),
            color: data.balance >= 0 ? AppColors.primary : AppColors.error,
            icon: Icons.account_balance_wallet_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(List<double> spending) {
    final daysToShow = spending.length > 30 ? 30 : spending.length;
    final recentSpending = spending.sublist(spending.length - daysToShow);

    final labels = <String>[];
    final now = DateTime.now();
    final step = (daysToShow / 5).ceil();
    for (int i = 0; i < daysToShow; i += step) {
      labels.add('${now.day - daysToShow + i + 1}');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Trend',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: SpendingLineChart(
                dataPoints: recentSpending,
                labels: labels,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToTransactions(context),
              child: const Text(
                'See All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...transactions.map(
            (tx) => TransactionCard(
              transaction: tx,
              onTap: () => _navigateToEditTransaction(context, tx),
              onDelete: () {
                context
                    .read<TransactionBloc>()
                    .add(DeleteTransactionEvent(transactionId: tx.id));
              },
            ),
          ),
      ],
    );
  }

  void _navigateToTransactions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TransactionsPage()),
    );
  }

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTransactionPage(),
      ),
    );
  }

  void _navigateToEditTransaction(
      BuildContext context, Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(transaction: transaction),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
