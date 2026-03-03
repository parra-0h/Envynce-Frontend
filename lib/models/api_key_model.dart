class ApiKey {
  final String id;
  final String name;
  final String prefix;
  final String? key; // Only present on creation
  final String status;
  final DateTime? lastUsed;
  final DateTime createdAt;

  ApiKey({
    required this.id,
    required this.name,
    required this.prefix,
    this.key,
    required this.status,
    this.lastUsed,
    required this.createdAt,
  });

  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      prefix: json['prefix'] as String? ?? '',
      key: json['key'] as String?,
      status: json['status'] as String? ?? 'active',
      lastUsed: json['last_used'] != null
          ? DateTime.tryParse(json['last_used'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
