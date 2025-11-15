import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.role,
  });

  factory AppUserModel.fromDoc(String id, Map<String, dynamic> data) {
    final roleString = data['role'] as String? ?? UserRole.cliente.name;
    return AppUserModel(
      id: id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.cliente,
      ),
    );
  }
}

