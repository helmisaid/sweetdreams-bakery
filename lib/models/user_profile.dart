class UserProfile {
  final int id;
  final String idUser;
  final String email;
  final String role;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.idUser,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      idUser: json['id_user'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_user': idUser,
      'role': role,
    };
  }
}
