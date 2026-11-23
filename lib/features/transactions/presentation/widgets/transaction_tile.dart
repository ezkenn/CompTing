import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/status_badge.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showSubmitter = false,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;
  final bool showSubmitter;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountColor = isIncome ? AppColors.success : AppColors.danger;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (transaction.categoryName != null)
                      transaction.categoryName!,
                    if (transaction.accountName != null)
                      transaction.accountName!,
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      DateFormatter.dateTime(transaction.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (showSubmitter && transaction.userName != null)
                      Text(
                        '• ${transaction.userName}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    if (transaction.hasReceipt)
                      const Icon(
                        Icons.attach_file_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                isIncome ? transaction.amount : -transaction.amount,
                showSign: true,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 8),
              StatusBadge.fromTransactionStatus(transaction.status),
            ],
          ),
        ],
      ),
    );
  }
}
