class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.actorId,
    required this.action,
    required this.targetTable,
    required this.targetId,
    required this.details,
    required this.createdAt,
    this.actorName,
    this.actorRole,
  });

  final String id;
  final String actorId;
  final String action;
  final String targetTable;
  final String targetId;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final String? actorName;
  final String? actorRole;

  String get readableSummary {
    final desc = details['description'] ?? details['party_name'];
    final status = details['status'];
    final note = details['rejection_note'];
    final parts = <String>[];
    if (desc != null) parts.add(desc.toString());
    if (status != null) parts.add('Status: $status');
    if (note != null && note.toString().isNotEmpty) {
      parts.add('Catatan: $note');
    }
    if (parts.isEmpty) {
      return details.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
    }
    return parts.join(' • ');
  }

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    final actorMap = json['profiles'] as Map<String, dynamic>?;
    final rawDetails = json['details'];
    return AuditLogModel(
      id: json['id'].toString(),
      actorId: json['actor_id'].toString(),
      action: (json['action'] as String?) ?? 'UPDATE',
      targetTable: (json['target_table'] as String?) ?? '',
      targetId: json['target_id'].toString(),
      details: rawDetails is Map<String, dynamic> ? rawDetails : const {},
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      actorName:
          (json['actor_name'] as String?) ?? (actorMap?['full_name'] as String?),
      actorRole:
          (json['actor_role'] as String?) ?? (actorMap?['role'] as String?),
    );
  }
}
