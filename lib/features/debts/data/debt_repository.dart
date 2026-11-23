import 'package:compting/core/services/notification_service.dart';
import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:compting/features/debts/domain/debt_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebtRepository {
  DebtRepository({
    required this.client,
  });

  final SupabaseClient client;

  Future<List<DebtModel>> fetchDebts() async {
    final rows = await client
        .from('debts_receivables')
        .select(
          'id, type, party_name, amount, due_date, status, notes, linked_transaction_id',
        )
        .order('due_date', ascending: true);

    return (rows as List<dynamic>)
        .map((e) => DebtModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DebtModel> createDebt({
    required UserProfile actor,
    required DebtType type,
    required String partyName,
    required double amount,
    required DateTime dueDate,
    String? notes,
    bool reminderEnabled = true,
  }) async {
    final row = await client
        .from('debts_receivables')
        .insert({
          'type': type.dbValue,
          'party_name': partyName,
          'amount': amount,
          'due_date': dueDate.toIso8601String().split('T').first,
          'status': DebtStatus.unpaid.dbValue,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'created_by': actor.id,
        })
        .select()
        .single();

    final created = DebtModel.fromJson(row).copyWith(
      reminderEnabled: reminderEnabled,
    );

    if (reminderEnabled) {
      await NotificationService.instance.scheduleDebtReminder(created);
    }

    return created;
  }

  Future<void> settleDebt({
    required DebtModel debt,
    required String accountId,
    required UserProfile actor,
  }) async {
    await client.rpc(
      'rpc_settle_debt',
      params: {
        'p_debt_id': debt.id,
        'p_account_id': accountId,
      },
    );

    await NotificationService.instance.cancelDebtReminder(debt);
  }
}
