import 'package:equatable/equatable.dart';

enum UserRole { cliente, chofer, admin }

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.role = UserRole.cliente,
  });

  final String id;
  final String email;
  final String? displayName;
  final UserRole role;

  bool get isChofer => role == UserRole.chofer;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, email, displayName, role];
}
