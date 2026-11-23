import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/features/approvals/presentation/pages/approval_queue_page.dart';
import 'package:compting/features/approvals/presentation/providers/approval_provider.dart';
import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/auth/presentation/widgets/profile_sheet.dart';
import 'package:compting/features/dashboard/presentation/pages/finance_dashboard_page.dart';
import 'package:compting/features/dashboard/presentation/pages/manager_dashboard_page.dart';
import 'package:compting/features/dashboard/presentation/pages/staf_dashboard_page.dart';
import 'package:compting/features/debts/presentation/pages/debt_list_page.dart';
import 'package:compting/features/reports/presentation/pages/reports_hub_page.dart';
import 'package:compting/features/transactions/presentation/pages/transaction_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kerangka navigasi bawah dinamis sesuai peran pengguna:
/// - Staf: 3 tab (Beranda, Transaksi, Utang/Piutang)
/// - Manager: 2 tab (Beranda, Approval)
/// - Finance: 2 tab (Beranda, Laporan & Log)
class RoleShellPage extends ConsumerStatefulWidget {
  const RoleShellPage({super.key});

  @override
  ConsumerState<RoleShellPage> createState() => _RoleShellPageState();
}

class _RoleShellPageState extends ConsumerState<RoleShellPage> {
  int _currentIndex = 0;

  void _setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pendingCount = user.role == UserRole.manager
        ? ref.watch(pendingApprovalsCountProvider)
        : 0;

    final tabs = _tabsForRole(user.role, pendingCount);
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.leaderboard_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tabs[safeIndex].title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'CompTing • ${user.role.label}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Profil & Ganti Akun',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
              ),
              onPressed: () => ProfileSheet.show(context),
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map((t) => t.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _setTab,
        destinations: tabs.map((t) => t.destination).toList(),
      ),
    );
  }

  List<_RoleTab> _tabsForRole(UserRole role, int pendingCount) {
    switch (role) {
      case UserRole.staf:
        return [
          _RoleTab(
            title: 'Beranda Staf',
            page: StafDashboardPage(onSwitchTab: _setTab),
            destination: const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
          ),
          const _RoleTab(
            title: 'Transaksi Lapangan',
            page: TransactionListPage(),
            destination: NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transaksi',
            ),
          ),
          const _RoleTab(
            title: 'Utang & Piutang',
            page: DebtListPage(),
            destination: NavigationDestination(
              icon: Icon(Icons.request_quote_outlined),
              selectedIcon: Icon(Icons.request_quote_rounded),
              label: 'Utang/Piutang',
            ),
          ),
        ];

      case UserRole.manager:
        return [
          _RoleTab(
            title: 'Beranda Manager',
            page: ManagerDashboardPage(onSwitchTab: _setTab),
            destination: const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Beranda',
            ),
          ),
          _RoleTab(
            title: 'Antrean Approval',
            page: const ApprovalQueuePage(),
            destination: NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.fact_check_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text('$pendingCount'),
                child: const Icon(Icons.fact_check_rounded),
              ),
              label: 'Approval',
            ),
          ),
        ];

      case UserRole.finance:
        return [
          _RoleTab(
            title: 'Beranda Finance',
            page: FinanceDashboardPage(onSwitchTab: _setTab),
            destination: const NavigationDestination(
              icon: Icon(Icons.account_balance_outlined),
              selectedIcon: Icon(Icons.account_balance_rounded),
              label: 'Beranda',
            ),
          ),
          const _RoleTab(
            title: 'Laporan & Audit Log',
            page: ReportsHubPage(),
            destination: NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics_rounded),
              label: 'Laporan & Log',
            ),
          ),
        ];
    }
  }
}

class _RoleTab {
  const _RoleTab({
    required this.title,
    required this.page,
    required this.destination,
  });

  final String title;
  final Widget page;
  final NavigationDestination destination;
}
