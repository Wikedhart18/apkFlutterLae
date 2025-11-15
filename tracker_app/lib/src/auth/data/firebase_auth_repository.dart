import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';

import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';
import 'models/app_user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const _usersCollection = 'users';

  @override
  Stream<AppUser?> watchUser() {
    return _auth.authStateChanges().asyncMap(_mapFirebaseUser);
  }

  Future<AppUser?> _mapFirebaseUser(User? firebaseUser) async {
    if (firebaseUser == null) return null;
    final doc = await _firestore
        .collection(_usersCollection)
        .doc(firebaseUser.uid)
        .get();

    final data = doc.data();
    if (data == null) {
      return AppUserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
      );
    }
    return AppUserModel.fromDoc(firebaseUser.uid, data);
  }

  @override
  Future<Either<String, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _mapFirebaseUser(credential.user);
      return right(user!);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Error de autenticación');
    } catch (e) {
      return left('Error inesperado al iniciar sesión');
    }
  }

  @override
  Future<Either<String, AppUser>> signUp({
    required String email,
    required String password,
    String? displayName,
    UserRole role = UserRole.cliente,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null) {
        await credential.user?.updateDisplayName(displayName);
      }

      await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .set({
            'email': email,
            'displayName': displayName,
            'role': role.name,
            'createdAt': FieldValue.serverTimestamp(),
          });

      final user = await _mapFirebaseUser(credential.user);
      return right(user!);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Error creando la cuenta');
    } catch (e) {
      return left('Error inesperado al registrarse');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
