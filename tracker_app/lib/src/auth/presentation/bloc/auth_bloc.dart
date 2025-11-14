import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState.unknown()) {
    on<_AuthStatusChanged>(_onStatusChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    _subscription = _repository.watchUser().listen(
      (user) => add(_AuthStatusChanged(user)),
    );
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> _onStatusChanged(
    _AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user == null) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(event.user!));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _repository.signIn(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (error) => emit(AuthState.failure(error)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _repository.signUp(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      role: event.role,
    );
    result.fold(
      (error) => emit(AuthState.failure(error)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.signOut();
    emit(const AuthState.unauthenticated());
  }
}
