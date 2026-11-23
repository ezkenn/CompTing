import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/router/route_paths.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/core/widgets/status_badge.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/dashboard/presentation/widgets/summary_metric_card.dart';
import 'package:compting/features/debts/presentation/providers/debt_provider.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:compting/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StafDashboardPage extends ConsumerWidget {
  const StafDashboardPage({super.key, required this.onSwitchTab});

  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final debtsAsync = ref.watch(debtsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(transactionsProvider);
        ref.invalidate(debtsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // Hero Card Staf
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkNavy, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${user?.fullName ?? 'Staf'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Catat transaksi lapangan lengkap dengan foto nota agar cepat di-approve Manager.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                  ),
                  onPressed: () => context.push(RoutePaths.transactionNew),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Catat Transaksi + Foto Nota'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ringkasan Status Pengajuan
          transactionsAsync.when(
            loading: () => const LoadingStateView(),
            error: (e, _) => ErrorRetryView(
              message: AppErrorMapper.toUserMessage(e),
              onRetry: () => ref.invalidate(transactionsProvider),
            ),
            data: (items) {
              final pendingCount = items
                  .where((t) => t.status == TransactionStatus.pending)
                  .length;
              final approvedCount = items
                  .where((t) => t.status == TransactionStatus.approved)
                  .length;
              final rejectedCount = items
                  .where((t) => t.status == TransactionStatus.rejected)
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SummaryMetricCard(
                          label: 'Pending',
                          value: '$pendingCount',
                          icon: Icons.schedule_rounded,
                          accentColor: AppColors.warning,
                          onTap: () => onSwitchTab(1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryMetricCard(
                          label: 'Disetujui',
                          value: '$approvedCount',
                          icon: Icons.check_circle_outline_rounded,
                          accentColor: AppColors.success,
                          onTap: () => onSwitchTab(1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SummaryMetricCard(
                          label: 'Ditolak',
                          value: '$rejectedCount',
                          icon: Icons.cancel_outlined,
                          accentColor: AppColors.danger,
                          onTap: () => onSwitchTab(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Pengingat Utang/Piutang Terdekat
                  debtsAsync.maybeWhen(
                    data: (debts) {
                      final upcoming = debts.where((d) => !d.isPaid).toList()
                        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
                      if (upcoming.isEmpty) return const SizedBox.shrink();
                      final nearest = upcoming.first;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jatuh Tempo Terdekat',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton(
                                onPressed: () => onSwitchTab(2),
                                child: const Text('Lihat Semua'),
                              ),
                            ],
                          ),
                          AppCard(
                            onTap: () => onSwitchTab(2),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningSurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nearest.partyName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${nearest.type.label} • ${DateFormatter.dueRelative(nearest.dueDate)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    CurrencyText(
                                      nearest.amount,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge.fromDebt(nearest),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pengajuan Terbaru Anda',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onSwitchTab(1),
                        child: const Text('Riwayat'),
                      ),
                    ],
                  ),
                  if (items.isEmpty)
                    const EmptyStateView(
                      icon: Icons.receipt_long_outlined,
                      title: 'Belum Ada Transaksi',
                      subtitle:
                          'Mulai catat pemasukan atau pengeluaran harian Anda.',
                    )
                  else
                    ...items
                        .take(5)
                        .map(
                          (trx) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(
                              transaction: trx,
                              onTap: () => context.push(
                                RoutePaths.transactionDetail,
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
