class Application {
  final String id;
  final String name;
  final String? description;
  final String? apiKey;
  final DateTime createdAt;

  Application({
    required this.id,
    required this.name,
    this.description,
    this.apiKey,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unnamed App',
      description: json['description'] as String?,
      apiKey: json['api_key'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'api_key': apiKey,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Application &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Environment {
  final String id;
  final String name;
  final String? description;
  final String color;

  Environment({
    required this.id,
    required this.name,
    this.description,
    required this.color,
  });

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] ?? '#3B82F6',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Environment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
