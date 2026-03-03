class ConfigurationItem {
  final String id;
  final String key;
  final String value;
  final String environment;
  final String? environmentId;
  final String version;
  final DateTime lastUpdated;
  final bool isActive;
  final String? description;

  ConfigurationItem({
    required this.id,
    required this.key,
    required this.value,
    required this.environment,
    this.environmentId,
    required this.version,
    required this.lastUpdated,
    required this.isActive,
    this.description,
  });

  factory ConfigurationItem.fromJson(Map<String, dynamic> json) {
    return ConfigurationItem(
      id: json['id']?.toString() ?? '',
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      environment:
          json['environment_name'] as String? ??
          json['environment_id']?.toString() ??
          'Unknown',
      environmentId: json['environment_id']?.toString(),
      version: json['version']?.toString() ?? '1',
      lastUpdated:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      isActive: json['is_active'] ?? true,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'environment_id': environmentId,
      'version': version,
      'is_active': isActive,
      'description': description,
    };
  }
}

class ConfigVersion {
  final String id;
  final String key;
  final String value;
  final String version;
  final DateTime createdAt;
  final String? createdBy;

  ConfigVersion({
    required this.id,
    required this.key,
    required this.value,
    required this.version,
    required this.createdAt,
    this.createdBy,
  });

  factory ConfigVersion.fromJson(Map<String, dynamic> json) {
    return ConfigVersion(
      id: json['id']?.toString() ?? '',
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      version: json['version']?.toString() ?? '1',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      createdBy: json['created_by_name'] as String?,
    );
  }
}
