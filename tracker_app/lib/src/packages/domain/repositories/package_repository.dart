import 'package:dartz/dartz.dart';

import 'package:tracker_app/src/auth/domain/entities/app_user.dart';
import '../entities/package.dart';

abstract class PackageRepository {
  Stream<List<Package>> watchPackagesForUser(AppUser user);

  Future<Either<String, Package>> createPackage({
    required String trackingId,
    required String clienteId,
    String? descripcion,
    String? origen,
    String? destino,
    String? choferId,
  });

  Future<Either<String, Package>> assignDriver({
    required String packageId,
    String? choferId,
  });

  Future<Either<String, Package>> updateStatus({
    required String packageId,
    required PackageStatus status,
  });

  Future<Either<String, Package>> updateLocation({
    required String packageId,
    required double lat,
    required double lng,
  });
}
