import 'package:compting/app.dart';
import 'package:compting/core/utils/currency_formatter.dart';
import 'package:compting/core/utils/validators.dart';
import 'package:compting/features/approvals/presentation/providers/approval_provider.dart';
import 'package:compting/features/approvals/presentation/widgets/reject_reason_dialog.dart';
import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/dashboard/presentation/pages/role_shell_page.dart';
import 'package:compting/features/debts/presentation/providers/debt_provider.dart';
import 'package:compting/features/reports/data/pdf_report_generator.dart';
import 'package:compting/features/reports/domain/financial_report_models.dart';
import 'package:compting/features/reports/presentation/providers/report_provider.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _stafUser = UserProfile(
  id: 'test-staf',
  fullName: 'Andi Pratama',
  email: 'staf@compting.app',
  role: UserRole.staf,
);

const _managerUser = UserProfile(
  id: 'test-manager',
  fullName: 'Budi Santoso',
  email: 'manager@compting.app',
  role: UserRole.manager,
);

const _financeUser = UserProfile(
  id: 'test-finance',
  fullName: 'Citra Wijaya',
  email: 'finance@compting.app',
  role: UserRole.finance,
);

final _emptyProfitLoss = ProfitLossReport(
  startDate: DateTime(2026, 11, 1),
  endDate: DateTime(2026, 11, 21),
  totalIncome: 0,
  totalExpense: 0,
  incomeBreakdown: const [],
  expenseBreakdown: const [],
);

final _emptyCashFlow = CashFlowReport(
  startDate: DateTime(2026, 11, 1),
  endDate: DateTime(2026, 11, 21),
  totalCashIn: 0,
  totalCashOut: 0,
  accounts: const [],
  series: const [],
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('Unit Tests — Formatter & Validator', () {
    test('CurrencyFormatter formats and parses Rupiah accurately', () {
      expect(CurrencyFormatter.format(1250000), 'Rp 1.250.000');
      expect(CurrencyFormatter.format(-50000), '-Rp 50.000');
      expect(CurrencyFormatter.parse('Rp 2.500.000'), 2500000);
    });

    test('AppValidators enforces mandatory rejection note', () {
      expect(AppValidators.rejectionNote(''), isNotNull);
      expect(AppValidators.rejectionNote('abc'), isNotNull);
      expect(
        AppValidators.rejectionNote('Nominal pada struk tidak sesuai'),
        isNull,
      );
    });

    test('PdfReportGenerator generates valid non-empty PDF bytes', () async {
      final bytes = await PdfReportGenerator.buildProfitLossPdf(
        report: ProfitLossReport(
          startDate: DateTime(2026, 11, 1),
          endDate: DateTime(2026, 11, 21),
          totalIncome: 15000000,
          totalExpense: 5000000,
          incomeBreakdown: const [
            CategoryBreakdown(
              categoryName: 'Penjualan Produk',
              costCenter: 'Sales',
              total: 15000000,
              transactionCount: 2,
            ),
          ],
          expenseBreakdown: const [
            CategoryBreakdown(
              categoryName: 'Operasional',
              costCenter: 'Ops',
              total: 5000000,
              transactionCount: 1,
            ),
          ],
        ),
        generatedBy: 'Citra Wijaya',
      );
      expect(bytes, isNotEmpty);
      // PDF header starts with "%PDF"
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });

  group('Widget Tests — Auth & Role-Based Navigation', () {
    testWidgets('Login page renders form without demo quick-fill chips', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: CompTingApp()));
      await tester.pumpAndSettle();

      expect(find.text('CompTing'), findsOneWidget);
      expect(find.text('Masuk ke Akun Anda'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
      expect(find.text('Quick-Fill Akun Demo (Presentasi)'), findsNothing);
    });

    testWidgets('RoleShellPage renders 3 tabs for Staf', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(_stafUser),
            transactionsProvider.overrideWith((ref) async => const []),
            debtsProvider.overrideWith((ref) async => const []),
            accountsProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: RoleShellPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Transaksi'), findsOneWidget);
      expect(find.text('Utang/Piutang'), findsOneWidget);
    });

    testWidgets('RoleShellPage renders 2 tabs for Manager', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(_managerUser),
            approvalTransactionsProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: RoleShellPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDestination), findsNWidgets(2));
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Approval'), findsOneWidget);
    });

    testWidgets('RoleShellPage renders 2 tabs for Finance', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(_financeUser),
            accountsProvider.overrideWith((ref) async => const []),
            profitLossReportProvider.overrideWith(
              (ref) async => _emptyProfitLoss,
            ),
            cashFlowReportProvider.overrideWith((ref) async => _emptyCashFlow),
            auditLogsProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: RoleShellPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDestination), findsNWidgets(2));
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Laporan & Log'), findsOneWidget);
    });

    testWidgets('RejectReasonDialog blocks submission when note is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RejectReasonDialog())),
      );

      await tester.tap(find.text('Tolak Transaksi'));
      await tester.pump();

      expect(find.text('Alasan penolakan wajib diisi'), findsOneWidget);
    });
  });
}
