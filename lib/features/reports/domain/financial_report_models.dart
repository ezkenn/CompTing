import 'package:compting/features/transactions/domain/account_model.dart';

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.categoryName,
    required this.costCenter,
    required this.total,
    required this.transactionCount,
  });

  final String categoryName;
  final String costCenter;
  final double total;
  final int transactionCount;
}

class ProfitLossReport {
  const ProfitLossReport({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
  });

  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpense;
  final List<CategoryBreakdown> incomeBreakdown;
  final List<CategoryBreakdown> expenseBreakdown;

  double get netProfit => totalIncome - totalExpense;
}

class CashFlowSeriesPoint {
  const CashFlowSeriesPoint({
    required this.label,
    required this.cashIn,
    required this.cashOut,
  });

  final String label;
  final double cashIn;
  final double cashOut;
}

class CashFlowReport {
  const CashFlowReport({
    required this.startDate,
    required this.endDate,
    required this.totalCashIn,
    required this.totalCashOut,
    required this.accounts,
    required this.series,
  });

  final DateTime startDate;
  final DateTime endDate;
  final double totalCashIn;
  final double totalCashOut;
  final List<AccountModel> accounts;
  final List<CashFlowSeriesPoint> series;

  double get netCashFlow => totalCashIn - totalCashOut;
  double get endingBalance =>
      accounts.fold(0, (sum, account) => sum + account.balance);
}
