import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../domain/entities/app_user.dart';
import '../domain/repositories/user_repository.dart';
import 'models/app_user_model.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _usersCollection = 'users';

  @override
  Future<Either<String, List<AppUser>>> fetchUsersByRole(UserRole role) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: role.name)
          .get();
      final users = snapshot.docs
          .map((doc) => AppUserModel.fromDoc(doc.id, doc.data()))
          .toList();
      return right(users);
    } catch (e) {
      return left('No se pudieron cargar los usuarios');
    }
  }
}

