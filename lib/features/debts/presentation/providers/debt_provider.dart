import 'package:compting/core/config/supabase_client.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/debts/data/debt_repository.dart';
import 'package:compting/features/debts/domain/debt_model.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository(
    client: ref.watch(supabaseClientProvider),
  );
});

final debtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(debtRepositoryProvider).fetchDebts();
});

class DebtActionController extends StateNotifier<AsyncValue<void>> {
  DebtActionController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> create({
    required DebtType type,
    required String partyName,
    required double amount,
    required DateTime dueDate,
    String? notes,
    bool reminderEnabled = true,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    state = const AsyncValue.loading();
    try {
      await _ref.read(debtRepositoryProvider).createDebt(
            actor: user,
            type: type,
            partyName: partyName,
            amount: amount,
            dueDate: dueDate,
            notes: notes,
            reminderEnabled: reminderEnabled,
          );
      _ref.invalidate(debtsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> settle({
    required DebtModel debt,
    required String accountId,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    state = const AsyncValue.loading();
    try {
      await _ref.read(debtRepositoryProvider).settleDebt(
            debt: debt,
            accountId: accountId,
            actor: user,
          );
      _ref.invalidate(debtsProvider);
      _ref.invalidate(accountsProvider);
      _ref.invalidate(transactionsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final debtActionProvider =
    StateNotifierProvider.autoDispose<DebtActionController, AsyncValue<void>>(
        (ref) {
  return DebtActionController(ref);
});
