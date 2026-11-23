import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApprovalRepository {
  ApprovalRepository({
    required this.client,
  });

  final SupabaseClient client;

  Future<List<TransactionModel>> fetchAllForApproval() async {
    final rows = await client.from('transactions').select('''
      id, user_id, account_id, category_id, type, amount, description,
      receipt_url, status, rejection_note, approved_by, created_at,
      profiles!transactions_user_id_fkey(full_name),
      accounts(name),
      categories(name, cost_center)
    ''').order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approve({
    required String transactionId,
    required UserProfile manager,
  }) async {
    // approved_by diisi secara mutlak oleh trigger server dari auth.uid()
    await client.from('transactions').update({
      'status': TransactionStatus.approved.dbValue,
    }).eq('id', transactionId);
  }

  Future<void> reject({
    required String transactionId,
    required UserProfile manager,
    required String rejectionNote,
  }) async {
    final cleanedNote = rejectionNote.trim();
    if (cleanedNote.isEmpty) {
      throw ArgumentError('Alasan penolakan tidak boleh kosong.');
    }

    // approved_by diisi secara mutlak oleh trigger server dari auth.uid()
    await client.from('transactions').update({
      'status': TransactionStatus.rejected.dbValue,
      'rejection_note': cleanedNote,
    }).eq('id', transactionId);
  }
}
