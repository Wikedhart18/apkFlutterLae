part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, failure }

class AuthState extends Equatable {
  const AuthState._({required this.status, this.user, this.message});

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(AppUser user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.failure(String message)
    : this._(status: AuthStatus.failure, message: message);

  final AuthStatus status;
  final AppUser? user;
  final String? message;

  @override
  List<Object?> get props => [status, user, message];
}
