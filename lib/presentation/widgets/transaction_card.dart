import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_arc/core/theme/app_theme.dart';
import 'package:spend_arc/domain/entities/transaction.dart';
import 'package:spend_arc/domain/entities/transaction_category.dart';
import 'package:spend_arc/presentation/widgets/particle_effect.dart';

class TransactionCard extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  double _dragX = 0;
  final GlobalKey<ParticleBurstState> _particleKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.5, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDelete?.call();
      }
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _resetPosition() {
    _swipeController.reverse();
    setState(() => _dragX = 0);
  }

  @override
  Widget build(BuildContext context) {
    final category = TransactionCategory.defaults
        .where((c) => c.id == widget.transaction.categoryId)
        .firstOrNull;

    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM d, yyyy');
    final isExpense = widget.transaction.type == TransactionType.expense;

    return ParticleBurst(
      key: _particleKey,
      color: AppColors.error,
      child: AnimatedBuilder(
        animation: _swipeAnimation,
        builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _swipeAnimation,
                builder: (context, _) {
                  final dismissAmount = _swipeAnimation.value.dx.abs();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.error.withValues(
                        alpha: dismissAmount.clamp(0.0, 0.3),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: Opacity(
                      opacity: dismissAmount.clamp(0.0, 1.0),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragX += details.delta.dx;
                  _dragX = _dragX.clamp(-150, 0);
                  _swipeController.value = (_dragX.abs() / 150).clamp(0.0, 1.0);
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragX < -100) {
                  _particleKey.currentState?.trigger();
                  _swipeController.forward();
                } else {
                  _resetPosition();
                }
              },
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(
                  _dragX,
                  0,
                  0,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.divider),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildCategoryIcon(category),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.transaction.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${category?.name ?? 'Other'} \u00b7 ${dateFormat.format(widget.transaction.date)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isExpense ? '-' : '+'}${currencyFormat.format(widget.transaction.amount)}',
                        style: TextStyle(
                          color: isExpense ? AppColors.expense : AppColors.income,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        },
      ),
    );
  }

  Widget _buildCategoryIcon(TransactionCategory? category) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: (category?.color ?? AppColors.primary).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        category?.icon ?? Icons.receipt_rounded,
        color: category?.color ?? AppColors.primary,
        size: 22,
      ),
    );
  }
}
