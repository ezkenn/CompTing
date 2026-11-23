enum DebtType {
  piutang('piutang', 'Piutang (Customer)'),
  utang('utang', 'Utang (Supplier)');

  const DebtType(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static DebtType fromString(String? value) {
    if (value?.toLowerCase() == 'utang') return DebtType.utang;
    return DebtType.piutang;
  }
}

enum DebtStatus {
  unpaid('unpaid', 'Belum Lunas'),
  paid('paid', 'Lunas');

  const DebtStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static DebtStatus fromString(String? value) {
    if (value?.toLowerCase() == 'paid') return DebtStatus.paid;
    return DebtStatus.unpaid;
  }
}

class DebtModel {
  const DebtModel({
    required this.id,
    required this.type,
    required this.partyName,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.linkedTransactionId,
    this.notes,
    this.reminderEnabled = true,
  });

  final String id;
  final DebtType type;
  final String partyName;
  final double amount;
  final DateTime dueDate;
  final DebtStatus status;
  final String? linkedTransactionId;
  final String? notes;
  final bool reminderEnabled;

  bool get isPaid => status == DebtStatus.paid;

  bool get isOverdue {
    if (isPaid) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  bool get isDueSoon {
    if (isPaid || isOverdue) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays <= 3;
  }

  int get notificationId => id.hashCode & 0x7fffffff;

  DebtModel copyWith({
    DebtStatus? status,
    String? linkedTransactionId,
    bool? reminderEnabled,
  }) {
    return DebtModel(
      id: id,
      type: type,
      partyName: partyName,
      amount: amount,
      dueDate: dueDate,
      status: status ?? this.status,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
      notes: notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'].toString(),
      type: DebtType.fromString(json['type'] as String?),
      partyName: (json['party_name'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dueDate:
          DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now(),
      status: DebtStatus.fromString(json['status'] as String?),
      linkedTransactionId: json['linked_transaction_id']?.toString(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'type': type.dbValue,
        'party_name': partyName,
        'amount': amount,
        'due_date': dueDate.toIso8601String().split('T').first,
        'status': status.dbValue,
        if (linkedTransactionId != null)
          'linked_transaction_id': linkedTransactionId,
      };
}
