import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/dashboard/presentation/widgets/cashflow_chart_card.dart';
import 'package:compting/features/reports/data/pdf_report_generator.dart';
import 'package:compting/features/reports/domain/financial_report_models.dart';
import 'package:compting/features/reports/presentation/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

class CashFlowSection extends ConsumerWidget {
  const CashFlowSection({super.key});

  Future<void> _exportPdf(
    BuildContext context,
    CashFlowReport report,
    String generatedBy,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Pratinjau PDF — Arus Kas')),
          body: PdfPreview(
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName: 'CompTing_Arus_Kas.pdf',
            build: (_) => PdfReportGenerator.buildCashFlowPdf(
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
    final cashFlowAsync = ref.watch(cashFlowReportProvider);
    final user = ref.watch(currentUserProvider);

    return cashFlowAsync.when(
      loading: () => const LoadingStateView(),
      error: (e, _) => ErrorRetryView(
        message: AppErrorMapper.toUserMessage(e),
        onRetry: () => ref.invalidate(cashFlowReportProvider),
      ),
      data: (report) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arus Kas Bersih Periode Ini',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CurrencyText(
                    report.netCashFlow,
                    showSign: true,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: report.netCashFlow >= 0
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kas Masuk',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      CurrencyText(
                        report.totalCashIn,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kas Keluar',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      CurrencyText(
                        report.totalCashOut,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
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
              label: const Text('Ekspor Laporan Arus Kas (PDF)'),
            ),
            const SizedBox(height: 16),
            CashFlowChartCard(series: report.series),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Posisi Saldo Akhir per Akun',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...report.accounts.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  account.type.label,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CurrencyText(
                            account.balance,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
