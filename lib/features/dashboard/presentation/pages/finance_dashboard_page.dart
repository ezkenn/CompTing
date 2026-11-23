import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/router/route_paths.dart';
import 'package:compting/core/utils/currency_formatter.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/dashboard/presentation/widgets/account_balance_carousel.dart';
import 'package:compting/features/dashboard/presentation/widgets/cashflow_chart_card.dart';
import 'package:compting/features/dashboard/presentation/widgets/summary_metric_card.dart';
import 'package:compting/features/reports/presentation/providers/report_provider.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FinanceDashboardPage extends ConsumerWidget {
  const FinanceDashboardPage({
    super.key,
    required this.onSwitchTab,
  });

  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final cashFlowAsync = ref.watch(cashFlowReportProvider);
    final profitLossAsync = ref.watch(profitLossReportProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(accountsProvider);
        ref.invalidate(cashFlowReportProvider);
        ref.invalidate(profitLossReportProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // Hero Card Total Kas & Bank
          accountsAsync.when(
            loading: () => const LoadingStateView(),
            error: (e, _) => ErrorRetryView(
              message: AppErrorMapper.toUserMessage(e),
              onRetry: () => ref.invalidate(accountsProvider),
            ),
            data: (accounts) {
              final totalBalance = accounts.fold<double>(
                0,
                (sum, a) => sum + a.balance,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.darkNavy, AppColors.primaryDeep],
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
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.accent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Total Posisi Kas & Bank (Real-Time)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CurrencyText(
                          totalBalance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                                onPressed: () => context.push(RoutePaths.debts),
                                icon: const Icon(
                                  Icons.request_quote_outlined,
                                  size: 17,
                                ),
                                label: const Text('Utang/Piutang'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 48),
                                ),
                                onPressed: () => onSwitchTab(1),
                                icon: const Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 17,
                                ),
                                label: const Text('Laporan PDF'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saldo per Rekening',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AccountBalanceCarousel(accounts: accounts),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Ringkasan Laba Rugi 30 Hari
          profitLossAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (pl) => Row(
              children: [
                Expanded(
                  child: SummaryMetricCard(
                    label: 'Pendapatan (30 Hr)',
                    value: CurrencyFormatter.formatCompact(pl.totalIncome),
                    icon: Icons.trending_up_rounded,
                    accentColor: AppColors.success,
                    onTap: () => onSwitchTab(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SummaryMetricCard(
                    label: 'Pengeluaran (30 Hr)',
                    value: CurrencyFormatter.formatCompact(pl.totalExpense),
                    icon: Icons.trending_down_rounded,
                    accentColor: AppColors.danger,
                    onTap: () => onSwitchTab(1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grafik Arus Kas
          cashFlowAsync.when(
            loading: () => const LoadingStateView(),
            error: (e, _) => ErrorRetryView(
              message: AppErrorMapper.toUserMessage(e),
              onRetry: () => ref.invalidate(cashFlowReportProvider),
            ),
            data: (cf) => CashFlowChartCard(series: cf.series),
          ),
        ],
      ),
    );
  }
}
