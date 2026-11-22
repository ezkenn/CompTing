import 'dart:io';

import 'package:compting/core/services/receipt_storage_service.dart';
import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:compting/features/transactions/domain/account_model.dart';
import 'package:compting/features/transactions/domain/category_model.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionRepository {
  TransactionRepository({
    required this.client,
    required this.receiptStorage,
  });

  final SupabaseClient client;
  final ReceiptStorageService receiptStorage;

  Future<List<AccountModel>> fetchAccounts({
    required UserProfile currentUser,
  }) async {
    if (currentUser.role == UserRole.finance) {
      final rows = await client
          .from('accounts')
          .select('id, name, type, balance')
          .order('name');
      return (rows as List<dynamic>)
          .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Staf & Manager hanya menerima daftar pilihan akun tanpa saldo perusahaan
    final rows = await client.rpc('rpc_list_account_options') as List<dynamic>;
    return rows
        .map((e) => AccountModel.fromJson({
              ...(e as Map<String, dynamic>),
              'balance': 0,
            }))
        .toList();
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final rows = await client
        .from('categories')
        .select('id, name, type, cost_center')
        .order('name');
    return (rows as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransactionModel>> fetchTransactions({
    required UserProfile currentUser,
  }) async {
    var query = client.from('transactions').select('''
      id, user_id, account_id, category_id, type, amount, description,
      receipt_url, status, rejection_note, approved_by, created_at,
      profiles!transactions_user_id_fkey(full_name),
      accounts(name),
      categories(name, cost_center)
    ''');

    if (currentUser.role == UserRole.staf) {
      query = query.eq('user_id', currentUser.id);
    }

    final rows = await query.order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionModel> createTransaction({
    required UserProfile actor,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required double amount,
    required String description,
    File? receiptFile,
  }) async {
    String? receiptUrl;
    if (receiptFile != null) {
      receiptUrl = await receiptStorage.uploadReceipt(
        file: receiptFile,
        userId: actor.id,
      );
    }

    final inserted = await client
        .from('transactions')
        .insert({
          'user_id': actor.id,
          'account_id': accountId,
          'category_id': categoryId,
          'type': type.dbValue,
          'amount': amount,
          'description': description,
          'receipt_url': receiptUrl,
          'status': TransactionStatus.pending.dbValue,
        })
        .select('''
          id, user_id, account_id, category_id, type, amount, description,
          receipt_url, status, rejection_note, approved_by, created_at,
          accounts(name),
          categories(name, cost_center)
        ''')
        .single();

    return TransactionModel.fromJson(inserted);
  }
}
