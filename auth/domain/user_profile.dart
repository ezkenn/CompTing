enum UserRole {
  staf('staf', 'Staf Operasional'),
  manager('manager', 'Manager'),
  finance('finance', 'Finance');

  const UserRole(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'manager':
        return UserRole.manager;
      case 'finance':
        return UserRole.finance;
      case 'staf':
      default:
        return UserRole.staf;
    }
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    String emailFallback = '',
  }) {
    return UserProfile(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? 'Pengguna CompTing',
      email: (json['email'] as String?) ?? emailFallback,
      role: UserRole.fromString(json['role'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role.dbValue,
      };
}
