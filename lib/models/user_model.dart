enum UserRole { admin, editor, viewer }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'Anonymous',
      role: _parseRole(json['role'] as String? ?? 'viewer'),
    );
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'editor':
        return UserRole.editor;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get canEdit => role == UserRole.admin || role == UserRole.editor;
}
