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
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      apiKey: json['api_key'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
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
}

class Environment {
  final String id;
  final String name;
  final String color;

  Environment({required this.id, required this.name, required this.color});

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      id: json['id'].toString(),
      name: json['name'] as String,
      color: json['color'] ?? '#3B82F6',
    );
  }
}
