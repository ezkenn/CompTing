import 'package:compting/core/router/route_paths.dart';
import 'package:compting/features/approvals/presentation/pages/approval_detail_page.dart';
import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:compting/features/auth/presentation/pages/login_page.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/dashboard/presentation/pages/role_shell_page.dart';
import 'package:compting/features/debts/presentation/pages/debt_form_page.dart';
import 'package:compting/features/debts/presentation/pages/debt_list_page.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:compting/features/transactions/presentation/pages/transaction_detail_page.dart';
import 'package:compting/features/transactions/presentation/pages/transaction_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

bool _isRouteAllowedForRole(String location, UserRole role) {
  switch (location) {
    case RoutePaths.transactionNew:
    case RoutePaths.debts:
    case RoutePaths.debtNew:
      return role == UserRole.staf || role == UserRole.finance;
    case RoutePaths.approvalDetail:
      return role == UserRole.manager;
    default:
      return true;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);

  ref.listen(currentUserProvider, (_, _) {
    refreshNotifier.value += 1;
  });

  return GoRouter(
    initialLocation: RoutePaths.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final location = state.matchedLocation;
      final isLoggingIn = location == RoutePaths.login;

      if (user == null) {
        return isLoggingIn ? null : RoutePaths.login;
      }
      if (isLoggingIn) {
        return RoutePaths.home;
      }
      if (!_isRouteAllowedForRole(location, user.role)) {
        return RoutePaths.home;
      }
      if ((location == RoutePaths.transactionDetail ||
              location == RoutePaths.approvalDetail) &&
          state.extra is! TransactionModel) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (_, _) => const RoleShellPage(),
      ),
      GoRoute(
        path: RoutePaths.transactionNew,
        builder: (_, _) => const TransactionFormPage(),
      ),
      GoRoute(
        path: RoutePaths.transactionDetail,
        builder: (_, state) {
          final trx = state.extra;
          if (trx is! TransactionModel) {
            return const RoleShellPage();
          }
          return TransactionDetailPage(transaction: trx);
        },
      ),
      GoRoute(
        path: RoutePaths.approvalDetail,
        builder: (_, state) {
          final trx = state.extra;
          if (trx is! TransactionModel) {
            return const RoleShellPage();
          }
          return ApprovalDetailPage(transaction: trx);
        },
      ),
      GoRoute(
        path: RoutePaths.debts,
        builder: (_, _) => const DebtListPage(standalone: true),
      ),
      GoRoute(
        path: RoutePaths.debtNew,
        builder: (_, _) => const DebtFormPage(),
      ),
    ],
  );
});
