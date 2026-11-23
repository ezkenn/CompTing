import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/router/route_paths.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/approvals/presentation/providers/approval_provider.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:compting/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ApprovalQueuePage extends ConsumerWidget {
  const ApprovalQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalsAsync = ref.watch(approvalTransactionsProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Antrean Pending'),
                Tab(text: 'Riwayat Keputusan'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: approvalsAsync.when(
              loading: () => const LoadingStateView(),
              error: (e, _) => ErrorRetryView(
                message: AppErrorMapper.toUserMessage(e),
                onRetry: () => ref.invalidate(approvalTransactionsProvider),
              ),
              data: (all) {
                final pending = all
                    .where((t) => t.status == TransactionStatus.pending)
                    .toList();
                final history = all
                    .where((t) => t.status != TransactionStatus.pending)
                    .toList();

                return TabBarView(
                  children: [
                    _ApprovalList(
                      items: pending,
                      emptyTitle: 'Tidak Ada Antrean Pending',
                      emptySubtitle:
                          'Semua pengajuan transaksi dari Staf sudah Anda tinjau.',
                      onRefresh: () async =>
                          ref.invalidate(approvalTransactionsProvider),
                    ),
                    _ApprovalList(
                      items: history,
                      emptyTitle: 'Belum Ada Riwayat Keputusan',
                      emptySubtitle:
                          'Transaksi yang disetujui atau ditolak akan tampil di sini.',
                      onRefresh: () async =>
                          ref.invalidate(approvalTransactionsProvider),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalList extends StatelessWidget {
  const _ApprovalList({
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
  });

  final List<TransactionModel> items;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.fact_check_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final trx = items[index];
          return TransactionTile(
            transaction: trx,
            showSubmitter: true,
            onTap: () => context.push(
              RoutePaths.approvalDetail,
              extra: trx,
            ),
          );
        },
      ),
    );
  }
}
