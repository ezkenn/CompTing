import 'package:compting/features/transactions/domain/category_model.dart';

enum TransactionStatus {
  pending('pending', 'Pending'),
  approved('approved', 'Disetujui'),
  rejected('rejected', 'Ditolak');

  const TransactionStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static TransactionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'approved':
        return TransactionStatus.approved;
      case 'rejected':
        return TransactionStatus.rejected;
      case 'pending':
      default:
        return TransactionStatus.pending;
    }
  }
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    this.receiptUrl,
    this.rejectionNote,
    this.approvedBy,
    this.userName,
    this.accountName,
    this.categoryName,
    this.costCenter,
    this.approvedByName,
  });

  final String id;
  final String userId;
  final String accountId;
  final String categoryId;
  final TransactionType type;
  final double amount;
  final String description;
  final String? receiptUrl;
  final TransactionStatus status;
  final String? rejectionNote;
  final String? approvedBy;
  final DateTime createdAt;

  // Joined / denormalized display fields
  final String? userName;
  final String? accountName;
  final String? categoryName;
  final String? costCenter;
  final String? approvedByName;

  bool get isIncome => type == TransactionType.income;
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;

  TransactionModel copyWith({
    TransactionStatus? status,
    String? rejectionNote,
    String? approvedBy,
    String? approvedByName,
    String? receiptUrl,
  }) {
    return TransactionModel(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      description: description,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      status: status ?? this.status,
      rejectionNote: rejectionNote ?? this.rejectionNote,
      approvedBy: approvedBy ?? this.approvedBy,
      createdAt: createdAt,
      userName: userName,
      accountName: accountName,
      categoryName: categoryName,
      costCenter: costCenter,
      approvedByName: approvedByName ?? this.approvedByName,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final profileMap = json['profiles'] as Map<String, dynamic>?;
    final accountMap = json['accounts'] as Map<String, dynamic>?;
    final categoryMap = json['categories'] as Map<String, dynamic>?;

    return TransactionModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      accountId: json['account_id'].toString(),
      categoryId: json['category_id'].toString(),
      type: TransactionType.fromString(json['type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      description: (json['description'] as String?) ?? '',
      receiptUrl: json['receipt_url'] as String?,
      status: TransactionStatus.fromString(json['status'] as String?),
      rejectionNote: json['rejection_note'] as String?,
      approvedBy: json['approved_by']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'].toString()) ??
          DateTime.now(),
      userName:
          (json['user_name'] as String?) ?? (profileMap?['full_name'] as String?),
      accountName:
          (json['account_name'] as String?) ?? (accountMap?['name'] as String?),
      categoryName: (json['category_name'] as String?) ??
          (categoryMap?['name'] as String?),
      costCenter: (json['cost_center'] as String?) ??
          (categoryMap?['cost_center'] as String?),
      approvedByName: json['approved_by_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'account_id': accountId,
        'category_id': categoryId,
        'type': type.dbValue,
        'amount': amount,
        'description': description,
        'receipt_url': receiptUrl,
        'status': status.dbValue,
      };
}
