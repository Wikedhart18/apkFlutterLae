part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class _AuthStatusChanged extends AuthEvent {
  const _AuthStatusChanged(this.user);

  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
    this.role = UserRole.cliente,
  });

  final String email;
  final String password;
  final String? displayName;
  final UserRole role;

  @override
  List<Object?> get props => [email, password, displayName, role];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
