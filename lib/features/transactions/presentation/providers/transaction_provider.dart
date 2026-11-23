import 'dart:io';

import 'package:compting/core/config/supabase_client.dart';
import 'package:compting/core/services/receipt_storage_service.dart';
import 'package:compting/features/auth/presentation/providers/auth_provider.dart';
import 'package:compting/features/transactions/data/transaction_repository.dart';
import 'package:compting/features/transactions/domain/account_model.dart';
import 'package:compting/features/transactions/domain/category_model.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final receiptStorageServiceProvider = Provider<ReceiptStorageService>((ref) {
  return ReceiptStorageService(client: ref.watch(supabaseClientProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
    client: ref.watch(supabaseClientProvider),
    receiptStorage: ref.watch(receiptStorageServiceProvider),
  );
});

final accountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref
      .watch(transactionRepositoryProvider)
      .fetchAccounts(currentUser: user);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(transactionRepositoryProvider).fetchCategories();
});

final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref
      .watch(transactionRepositoryProvider)
      .fetchTransactions(currentUser: user);
});

class TransactionSubmissionController extends StateNotifier<AsyncValue<void>> {
  TransactionSubmissionController(this._ref)
      : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> submit({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required double amount,
    required String description,
    File? receiptFile,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    state = const AsyncValue.loading();
    try {
      await _ref.read(transactionRepositoryProvider).createTransaction(
            actor: user,
            accountId: accountId,
            categoryId: categoryId,
            type: type,
            amount: amount,
            description: description,
            receiptFile: receiptFile,
          );
      _ref.invalidate(transactionsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final transactionSubmissionProvider = StateNotifierProvider.autoDispose<
    TransactionSubmissionController, AsyncValue<void>>((ref) {
  return TransactionSubmissionController(ref);
});
