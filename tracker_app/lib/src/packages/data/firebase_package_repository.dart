import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:tracker_app/src/auth/domain/entities/app_user.dart';
import '../domain/entities/package.dart';
import '../domain/repositories/package_repository.dart';

class FirebasePackageRepository implements PackageRepository {
  FirebasePackageRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _collection = 'packages';

  @override
  Stream<List<Package>> watchPackagesForUser(AppUser user) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_collection)
        .orderBy('updatedAt', descending: true);

    if (user.isChofer) {
      query = query.where('choferId', isEqualTo: user.id);
    } else if (!user.isAdmin) {
      query = query.where('clienteId', isEqualTo: user.id);
    }

    return query
        .snapshots()
        .map((snapshot) {
          // DEBUG: imprimir cantidad de paquetes por rol/usuario
          // ignore: avoid_print
          print(
            'Paquetes para ${user.role.name} (${user.id}): ${snapshot.docs.length}',
          );
          return snapshot.docs
              .map((doc) => _fromDoc(doc.id, doc.data()))
              .toList(growable: false);
        })
        .handleError((error) {
          // DEBUG: capturar errores del stream
          // ignore: avoid_print
          print('STREAM ERROR watchPackagesForUser: $error');
        });
  }

  Package _fromDoc(String id, Map<String, dynamic> data) {
    return Package(
      id: id,
      trackingId: data['trackingId'] as String,
      clienteId: data['clienteId'] as String,
      choferId: data['choferId'] as String?,
      estado: PackageStatus.values.firstWhere(
        (status) => status.name == (data['estado'] as String? ?? 'creado'),
        orElse: () => PackageStatus.creado,
      ),
      descripcion: data['descripcion'] as String?,
      origen: data['origen'] as String?,
      destino: data['destino'] as String?,
      lastLat: (data['lastLat'] as num?)?.toDouble(),
      lastLng: (data['lastLng'] as num?)?.toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<Either<String, Package>> createPackage({
    required String trackingId,
    required String clienteId,
    String? descripcion,
    String? origen,
    String? destino,
    String? choferId,
  }) async {
    try {
      final doc = await _firestore.collection(_collection).add({
        'trackingId': trackingId,
        'clienteId': clienteId,
        'choferId': choferId,
        'descripcion': descripcion,
        'origen': origen,
        'destino': destino,
        'estado':
            (choferId != null ? PackageStatus.asignado : PackageStatus.creado)
                .name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final snapshot = await doc.get();
      return right(_fromDoc(doc.id, snapshot.data()!));
    } catch (e) {
      return left('Error creando paquete');
    }
  }

  @override
  Future<Either<String, Package>> assignDriver({
    required String packageId,
    String? choferId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(packageId).update({
        'choferId': choferId,
        'estado':
            (choferId == null ? PackageStatus.creado : PackageStatus.asignado)
                .name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final doc = await _firestore.collection(_collection).doc(packageId).get();
      return right(_fromDoc(doc.id, doc.data()!));
    } catch (e) {
      return left('No se pudo asignar el chofer');
    }
  }

  @override
  Future<Either<String, Package>> updateStatus({
    required String packageId,
    required PackageStatus status,
  }) async {
    try {
      await _firestore.collection(_collection).doc(packageId).update({
        'estado': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final doc = await _firestore.collection(_collection).doc(packageId).get();
      return right(_fromDoc(doc.id, doc.data()!));
    } catch (e) {
      return left('No se pudo actualizar el estado');
    }
  }

  @override
  Future<Either<String, Package>> updateLocation({
    required String packageId,
    required double lat,
    required double lng,
  }) async {
    try {
      await _firestore.collection(_collection).doc(packageId).update({
        'lastLat': lat,
        'lastLng': lng,
        'estado': PackageStatus.enRuta.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final doc = await _firestore.collection(_collection).doc(packageId).get();
      return right(_fromDoc(doc.id, doc.data()!));
    } catch (e) {
      return left('No se pudo actualizar la ubicación');
    }
  }
}
