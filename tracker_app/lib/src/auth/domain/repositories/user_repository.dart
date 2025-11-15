import 'package:dartz/dartz.dart';

import '../entities/app_user.dart';

abstract class UserRepository {
  Future<Either<String, List<AppUser>>> fetchUsersByRole(UserRole role);
}

