class AuditLog {
  final String id;
  final String action;
  final String entity;
  final String entityId;
  final String? oldValue;
  final String? newValue;
  final String changedBy;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    required this.action,
    required this.entity,
    required this.entityId,
    this.oldValue,
    this.newValue,
    required this.changedBy,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id']?.toString() ?? '',
      action: json['action'] as String? ?? 'UNKNOWN',
      entity: json['entity'] as String? ?? 'System',
      entityId: json['entity_id']?.toString() ?? '',
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      changedBy: json['changed_by'] as String? ?? 'System',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
