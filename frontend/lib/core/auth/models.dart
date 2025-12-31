enum UserRole {
  admin,
  teacher,
  student,
  unknown,
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageUrl,
    this.lastLogin,
  });

  //vérifier si l'utilisateur est admin
  bool get isAdmin => role == UserRole.admin;
  
  // vérifier si l'utilisateur est professeur
  bool get isTeacher => role == UserRole.teacher;
  
  // vérifier si l'utilisateur est étudiant
  bool get isStudent => role == UserRole.student;

  // Convertir depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '0',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: _parseRole(json['role']),
      profileImageUrl: json['profileImageUrl'],
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin']) 
          : null,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Parser le rôle depuis une chaîne
  static UserRole _parseRole(String role) {
    if (role is String) {
      switch (role.toLowerCase()) {
        case 'admin':
          return UserRole.admin;
        case 'teacher':
          return UserRole.teacher;
        case 'student':
          return UserRole.student;
        default:
          return UserRole.unknown;
      }
    }
    return UserRole.unknown;
  }

  // Copier avec modifications - VERSION CORRIGÉE
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? profileImageUrl,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}