import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/reports/data/pdf_report_generator.dart';
import 'package:compting/features/reports/domain/financial_report_models.dart';
import 'package:compting/features/reports/presentation/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

class ProfitLossSection extends ConsumerWidget {
  const ProfitLossSection({super.key});

  Future<void> _exportPdf(
    BuildContext context,
    ProfitLossReport report,
    String generatedBy,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Pratinjau PDF — Laba Rugi')),
          body: PdfPreview(
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName: 'CompTing_Laba_Rugi.pdf',
            build: (_) => PdfReportGenerator.buildProfitLossPdf(
              report: report,
              generatedBy: generatedBy,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(profitLossReportProvider);
    final user = ref.watch(currentUserProvider);

    return reportAsync.when(
      loading: () => const LoadingStateView(),
      error: (e, _) => ErrorRetryView(
        message: AppErrorMapper.toUserMessage(e),
        onRetry: () => ref.invalidate(profitLossReportProvider),
      ),
      data: (report) {
        final isProfit = report.netProfit >= 0;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            AppCard(
              backgroundColor:
                  isProfit ? AppColors.successSurface : AppColors.dangerSurface,
              borderColor: (isProfit ? AppColors.success : AppColors.danger)
                  .withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isProfit ? 'Laba Bersih Periode Ini' : 'Rugi Bersih Periode Ini',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CurrencyText(
                    report.netProfit,
                    showSign: true,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isProfit ? AppColors.success : AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniTotal(
                          label: 'Total Pendapatan',
                          amount: report.totalIncome,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniTotal(
                          label: 'Total Beban',
                          amount: report.totalExpense,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () => _exportPdf(
                context,
                report,
                user?.fullName ?? 'Finance',
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Ekspor Laporan Laba Rugi (PDF)'),
            ),
            const SizedBox(height: 18),
            _BreakdownCard(
              title: 'Rincian Pendapatan',
              items: report.incomeBreakdown,
              accentColor: AppColors.success,
            ),
            const SizedBox(height: 12),
            _BreakdownCard(
              title: 'Rincian Beban & Pengeluaran',
              items: report.expenseBreakdown,
              accentColor: AppColors.danger,
            ),
          ],
        );
      },
    );
  }
}

class _MiniTotal extends StatelessWidget {
  const _MiniTotal({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          CurrencyText(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.title,
    required this.items,
    required this.accentColor,
  });

  final String title;
  final List<CategoryBreakdown> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text(
              'Belum ada transaksi disetujui pada kategori ini.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.categoryName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${item.costCenter} • ${item.transactionCount} transaksi',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CurrencyText(
                      item.total,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
