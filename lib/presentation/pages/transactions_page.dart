import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spend_arc/core/theme/app_theme.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_event.dart';
import 'package:spend_arc/presentation/bloc/transaction/transaction_state.dart';
import 'package:spend_arc/presentation/pages/add_transaction_page.dart';
import 'package:spend_arc/presentation/widgets/empty_state.dart';
import 'package:spend_arc/presentation/widgets/transaction_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is TransactionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is TransactionLoaded) {
            final transactions = state.transactions;
            if (transactions.isEmpty) {
              return const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No transactions yet',
                subtitle: 'Tap + to add your first transaction',
              );
            }

            final grouped = _groupByDate(transactions);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (tx) => TransactionCard(
                        transaction: tx,
                        onTap: () => _navigateToEdit(context, tx),
                        onDelete: () {
                          context
                              .read<TransactionBloc>()
                              .add(DeleteTransactionEvent(transactionId: tx.id));
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final dateFormat = DateFormat('MMMM d, yyyy');

    for (final tx in transactions) {
      String label;
      if (_isSameDay(tx.date, today)) {
        label = 'Today';
      } else if (_isSameDay(tx.date, yesterday)) {
        label = 'Yesterday';
      } else {
        label = dateFormat.format(tx.date);
      }

      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(tx);
    }
    return grouped;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _navigateToEdit(BuildContext context, Transaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(transaction: transaction),
      ),
    );
  }
}
