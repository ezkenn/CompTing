import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/reports/presentation/providers/report_provider.dart';
import 'package:compting/features/reports/presentation/widgets/audit_log_tile.dart';
import 'package:compting/features/reports/presentation/widgets/cash_flow_section.dart';
import 'package:compting/features/reports/presentation/widgets/profit_loss_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsHubPage extends ConsumerWidget {
  const ReportsHubPage({super.key});

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final current = ref.read(reportDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: current,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      ref.read(reportDateRangeProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reportDateRangeProvider);
    final logsAsync = ref.watch(auditLogsProvider);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.date_range_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${DateFormatter.shortDate(range.start)} – ${DateFormatter.shortDate(range.end)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _pickRange(context, ref),
                      child: const Text('Ubah Periode'),
                    ),
                  ],
                ),
                const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Laba Rugi'),
                    Tab(text: 'Arus Kas'),
                    Tab(text: 'Audit Log'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              children: [
                const ProfitLossSection(),
                const CashFlowSection(),
                logsAsync.when(
                  loading: () => const LoadingStateView(),
                  error: (e, _) => ErrorRetryView(
                    message: AppErrorMapper.toUserMessage(e),
                    onRetry: () => ref.invalidate(auditLogsProvider),
                  ),
                  data: (logs) {
                    if (logs.isEmpty) {
                      return const EmptyStateView(
                        icon: Icons.history_rounded,
                        title: 'Belum Ada Audit Log',
                        subtitle:
                            'Rekam jejak otomatis transaksi & persetujuan akan tampil di sini.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(auditLogsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                        itemCount: logs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) =>
                            AuditLogTile(log: logs[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
