import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/features/reports/domain/audit_log_model.dart';
import 'package:compting/features/reports/domain/financial_report_models.dart';
import 'package:compting/features/transactions/domain/account_model.dart';
import 'package:compting/features/transactions/domain/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportRepository {
  ReportRepository({
    required this.client,
  });

  final SupabaseClient client;

  Future<List<AuditLogModel>> fetchAuditLogs() async {
    final rows = await client.from('audit_logs').select('''
      id, actor_id, action, target_table, target_id, details, created_at,
      profiles(full_name, role)
    ''').order('created_at', ascending: false).limit(100);

    return (rows as List<dynamic>)
        .map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProfitLossReport> fetchProfitLoss({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final endInclusive = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );
    final rows = await client.rpc(
      'rpc_profit_loss_summary',
      params: {
        'p_start': startDate.toIso8601String(),
        'p_end': endInclusive.toIso8601String(),
      },
    ) as List<dynamic>;

    final incomeBreakdown = <CategoryBreakdown>[];
    final expenseBreakdown = <CategoryBreakdown>[];
    double totalIncome = 0;
    double totalExpense = 0;

    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final total = (row['total_amount'] as num?)?.toDouble() ?? 0;
      final item = CategoryBreakdown(
        categoryName: (row['category_name'] as String?) ?? 'Lainnya',
        costCenter: (row['cost_center'] as String?) ?? 'Umum',
        total: total,
        transactionCount: (row['transaction_count'] as num?)?.toInt() ?? 0,
      );
      if (row['type'] == TransactionType.income.dbValue) {
        totalIncome += total;
        incomeBreakdown.add(item);
      } else {
        totalExpense += total;
        expenseBreakdown.add(item);
      }
    }

    return ProfitLossReport(
      startDate: startDate,
      endDate: endDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      incomeBreakdown: incomeBreakdown,
      expenseBreakdown: expenseBreakdown,
    );
  }

  Future<CashFlowReport> fetchCashFlow({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final accounts = await _fetchAccounts();
    final endInclusive = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );
    final rows = await client.rpc(
      'rpc_cash_flow_series',
      params: {
        'p_start': startDate.toIso8601String(),
        'p_end': endInclusive.toIso8601String(),
      },
    ) as List<dynamic>;

    double totalIn = 0;
    double totalOut = 0;
    final series = <CashFlowSeriesPoint>[];

    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final cashIn = (row['cash_in'] as num?)?.toDouble() ?? 0;
      final cashOut = (row['cash_out'] as num?)?.toDouble() ?? 0;
      final date =
          DateTime.tryParse(row['bucket_date'].toString()) ?? startDate;
      totalIn += cashIn;
      totalOut += cashOut;
      series.add(
        CashFlowSeriesPoint(
          label: DateFormatter.dayMonth(date),
          cashIn: cashIn,
          cashOut: cashOut,
        ),
      );
    }

    return CashFlowReport(
      startDate: startDate,
      endDate: endDate,
      totalCashIn: totalIn,
      totalCashOut: totalOut,
      accounts: accounts,
      series: series,
    );
  }

  Future<List<AccountModel>> _fetchAccounts() async {
    final rows = await client
        .from('accounts')
        .select('id, name, type, balance')
        .order('name');
    return (rows as List<dynamic>)
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
