import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/router/route_paths.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/approvals/presentation/providers/approval_provider.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/dashboard/presentation/widgets/summary_metric_card.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:compting/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManagerDashboardPage extends ConsumerWidget {
  const ManagerDashboardPage({
    super.key,
    required this.onSwitchTab,
  });

  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final approvalsAsync = ref.watch(approvalTransactionsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(approvalTransactionsProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          approvalsAsync.when(
            loading: () => const LoadingStateView(),
            error: (e, _) => ErrorRetryView(
              message: AppErrorMapper.toUserMessage(e),
              onRetry: () => ref.invalidate(approvalTransactionsProvider),
            ),
            data: (items) {
              final pending = items
                  .where((t) => t.status == TransactionStatus.pending)
                  .toList();
              final approved = items
                  .where((t) => t.status == TransactionStatus.approved)
                  .length;
              final rejected = items
                  .where((t) => t.status == TransactionStatus.rejected)
                  .length;
              final pendingTotal = pending.fold<double>(
                0,
                (sum, t) => sum + t.amount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending Alert Hero Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDeep, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '${pending.length} Menunggu Persetujuan',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Halo, ${user?.fullName ?? 'Manager'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        CurrencyText(
                          pendingTotal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total nominal antrean pending saat ini',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 46),
                          ),
                          onPressed: () => onSwitchTab(1),
                          icon: const Icon(Icons.fact_check_outlined, size: 18),
                          label: const Text('Tinjau Antrean Approval'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryMetricCard(
                          label: 'Sudah Disetujui',
                          value: '$approved',
                          icon: Icons.verified_outlined,
                          accentColor: AppColors.success,
                          onTap: () => onSwitchTab(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryMetricCard(
                          label: 'Ditolak (Revisi)',
                          value: '$rejected',
                          icon: Icons.cancel_outlined,
                          accentColor: AppColors.danger,
                          onTap: () => onSwitchTab(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Antrean Prioritas',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onSwitchTab(1),
                        child: const Text('Buka Semua'),
                      ),
                    ],
                  ),
                  if (pending.isEmpty)
                    const EmptyStateView(
                      icon: Icons.done_all_rounded,
                      title: 'Semua Pengajuan Sudah Diproses',
                      subtitle:
                          'Tidak ada transaksi pending yang menunggu persetujuan saat ini.',
                    )
                  else
                    ...pending.take(4).map(
                          (trx) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(
                              transaction: trx,
                              showSubmitter: true,
                              onTap: () => context.push(
                                RoutePaths.approvalDetail,
                                extra: trx,
                              ),
                            ),
                          ),
                        ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
