import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/receipt_viewer_page.dart';
import 'package:compting/core/widgets/status_badge.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor =
        transaction.isIncome ? AppColors.success : AppColors.danger;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.type.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                    StatusBadge.fromTransactionStatus(transaction.status),
                  ],
                ),
                const SizedBox(height: 8),
                CurrencyText(
                  transaction.isIncome
                      ? transaction.amount
                      : -transaction.amount,
                  showSign: true,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Divider(height: 28),
                _DetailRow(
                  label: 'Akun Kas / Bank',
                  value: transaction.accountName ?? '-',
                ),
                _DetailRow(
                  label: 'Kategori',
                  value: transaction.categoryName ?? '-',
                ),
                _DetailRow(
                  label: 'Cost Center',
                  value: transaction.costCenter ?? '-',
                ),
                _DetailRow(
                  label: 'Waktu Input',
                  value: DateFormatter.dateTime(transaction.createdAt),
                ),
                if (transaction.approvedByName != null)
                  _DetailRow(
                    label: 'Diproses Oleh',
                    value: transaction.approvedByName!,
                  ),
              ],
            ),
          ),

          if (transaction.status == TransactionStatus.rejected &&
              (transaction.rejectionNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            AppCard(
              backgroundColor: AppColors.dangerSurface,
              borderColor: AppColors.danger.withValues(alpha: 0.4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alasan Penolakan Manager',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.danger,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.rejectionNote!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (transaction.hasReceipt) ...[
            const SizedBox(height: 16),
            const Text(
              'Bukti Nota / Struk',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(10),
              onTap: () => ReceiptViewerPage.open(
                context,
                receiptUrl: transaction.receiptUrl!,
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ReceiptImageWidget(
                      receiptUrl: transaction.receiptUrl!,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.zoom_in_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Ketuk foto untuk memperbesar (Fullscreen Zoom)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
