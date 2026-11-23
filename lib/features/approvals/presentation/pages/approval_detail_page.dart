import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/receipt_viewer_page.dart';
import 'package:compting/core/widgets/status_badge.dart';
import 'package:compting/features/approvals/presentation/providers/approval_provider.dart';
import 'package:compting/features/approvals/presentation/widgets/reject_reason_dialog.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ApprovalDetailPage extends ConsumerWidget {
  const ApprovalDetailPage({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Transaksi?'),
        content: const Text(
          'Menyetujui transaksi ini akan otomatis memperbarui saldo akun kas/bank, mencatat ke Buku Besar (Ledger), dan merekam Audit Log.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: const Size(110, 42),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final ok = await ref
        .read(approvalActionProvider.notifier)
        .approve(transaction.id);

    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi disetujui! Saldo & Ledger ter-update.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(approvalActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err != null
                ? AppErrorMapper.toUserMessage(err)
                : 'Gagal menyetujui transaksi.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final note = await RejectReasonDialog.show(context);
    if (note == null || note.isEmpty) return;

    final ok = await ref.read(approvalActionProvider.notifier).reject(
          transactionId: transaction.id,
          rejectionNote: note,
        );

    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi ditolak dengan catatan alasan.'),
          backgroundColor: AppColors.warning,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(approvalActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err != null
                ? AppErrorMapper.toUserMessage(err)
                : 'Gagal menolak transaksi.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(approvalActionProvider);
    final isPending = transaction.status == TransactionStatus.pending;
    final amountColor =
        transaction.isIncome ? AppColors.success : AppColors.danger;

    return Scaffold(
      appBar: AppBar(title: const Text('Tinjau Pengajuan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
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
                const SizedBox(height: 10),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 26),
                _MetaRow('Diajukan Oleh', transaction.userName ?? 'Staf'),
                _MetaRow('Akun Kas/Bank', transaction.accountName ?? '-'),
                _MetaRow('Kategori', transaction.categoryName ?? '-'),
                _MetaRow('Cost Center', transaction.costCenter ?? '-'),
                _MetaRow(
                  'Tanggal Input',
                  DateFormatter.dateTime(transaction.createdAt),
                ),
              ],
            ),
          ),

          if ((transaction.rejectionNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            AppCard(
              backgroundColor: AppColors.dangerSurface,
              borderColor: AppColors.danger.withValues(alpha: 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catatan Penolakan',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(transaction.rejectionNote!),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text(
            'Verifikasi Foto Nota Fisik',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (transaction.hasReceipt)
            AppCard(
              padding: const EdgeInsets.all(10),
              onTap: () => ReceiptViewerPage.open(
                context,
                receiptUrl: transaction.receiptUrl!,
                title: 'Verifikasi Nota',
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ReceiptImageWidget(
                      receiptUrl: transaction.receiptUrl!,
                      height: 220,
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
                        'Ketuk untuk perbesar nota (Pinch-to-Zoom)',
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
            )
          else
            const AppCard(
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.warning),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tidak ada foto bukti nota yang dilampirkan pada pengajuan ini.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: isPending
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          minimumSize: const Size(0, 50),
                        ),
                        onPressed: actionState.isLoading
                            ? null
                            : () => _handleReject(context, ref),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(0, 50),
                        ),
                        onPressed: actionState.isLoading
                            ? null
                            : () => _handleApprove(context, ref),
                        icon: actionState.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Setujui Transaksi'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
