import 'package:compting/core/config/supabase_client.dart';
import 'package:compting/features/approvals/data/approval_repository.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final approvalRepositoryProvider = Provider<ApprovalRepository>((ref) {
  return ApprovalRepository(
    client: ref.watch(supabaseClientProvider),
  );
});

final approvalTransactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(approvalRepositoryProvider).fetchAllForApproval();
});

final pendingApprovalsCountProvider = Provider<int>((ref) {
  final list = ref.watch(approvalTransactionsProvider).valueOrNull ?? const [];
  return list.where((t) => t.status == TransactionStatus.pending).length;
});

class ApprovalActionController extends StateNotifier<AsyncValue<void>> {
  ApprovalActionController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> approve(String transactionId) async {
    final manager = _ref.read(currentUserProvider);
    if (manager == null) return false;

    state = const AsyncValue.loading();
    try {
      await _ref.read(approvalRepositoryProvider).approve(
            transactionId: transactionId,
            manager: manager,
          );
      _ref.invalidate(approvalTransactionsProvider);
      _ref.invalidate(transactionsProvider);
      _ref.invalidate(accountsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> reject({
    required String transactionId,
    required String rejectionNote,
  }) async {
    final manager = _ref.read(currentUserProvider);
    if (manager == null) return false;

    state = const AsyncValue.loading();
    try {
      await _ref.read(approvalRepositoryProvider).reject(
            transactionId: transactionId,
            manager: manager,
            rejectionNote: rejectionNote,
          );
      _ref.invalidate(approvalTransactionsProvider);
      _ref.invalidate(transactionsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final approvalActionProvider =
    StateNotifierProvider.autoDispose<ApprovalActionController, AsyncValue<void>>(
        (ref) {
  return ApprovalActionController(ref);
});
