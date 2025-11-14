import 'package:dartz/dartz.dart';

import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchUser();

  Future<Either<String, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, AppUser>> signUp({
    required String email,
    required String password,
    String? displayName,
    UserRole role = UserRole.cliente,
  });

  Future<void> signOut();
}
