import 'package:compting/core/config/supabase_client.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/reports/data/report_repository.dart';
import 'package:compting/features/reports/domain/audit_log_model.dart';
import 'package:compting/features/reports/domain/financial_report_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(
    client: ref.watch(supabaseClientProvider),
  );
});

final reportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: now.subtract(const Duration(days: 30)),
    end: now,
  );
});

final profitLossReportProvider = FutureProvider<ProfitLossReport>((ref) async {
  final user = ref.watch(currentUserProvider);
  final range = ref.watch(reportDateRangeProvider);
  if (user == null) {
    return ProfitLossReport(
      startDate: range.start,
      endDate: range.end,
      totalIncome: 0,
      totalExpense: 0,
      incomeBreakdown: const [],
      expenseBreakdown: const [],
    );
  }
  return ref.watch(reportRepositoryProvider).fetchProfitLoss(
        startDate: range.start,
        endDate: range.end,
      );
});

final cashFlowReportProvider = FutureProvider<CashFlowReport>((ref) async {
  final user = ref.watch(currentUserProvider);
  final range = ref.watch(reportDateRangeProvider);
  if (user == null) {
    return CashFlowReport(
      startDate: range.start,
      endDate: range.end,
      totalCashIn: 0,
      totalCashOut: 0,
      accounts: const [],
      series: const [],
    );
  }
  return ref.watch(reportRepositoryProvider).fetchCashFlow(
        startDate: range.start,
        endDate: range.end,
      );
});

final auditLogsProvider = FutureProvider<List<AuditLogModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(reportRepositoryProvider).fetchAuditLogs();
});
