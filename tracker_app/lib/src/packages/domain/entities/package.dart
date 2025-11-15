import 'package:equatable/equatable.dart';

enum PackageStatus { creado, asignado, enRuta, entregado, incidentado }

class Package extends Equatable {
  const Package({
    required this.id,
    required this.trackingId,
    required this.clienteId,
    this.choferId,
    this.estado = PackageStatus.creado,
    this.descripcion,
    this.origen,
    this.destino,
    this.lastLat,
    this.lastLng,
    this.updatedAt,
  });

  final String id;
  final String trackingId;
  final String clienteId;
  final String? choferId;
  final PackageStatus estado;
  final String? descripcion;
  final String? origen;
  final String? destino;
  final double? lastLat;
  final double? lastLng;
  final DateTime? updatedAt;

  Package copyWith({
    String? id,
    String? trackingId,
    String? clienteId,
    String? choferId,
    PackageStatus? estado,
    String? descripcion,
    String? origen,
    String? destino,
    double? lastLat,
    double? lastLng,
    DateTime? updatedAt,
  }) {
    return Package(
      id: id ?? this.id,
      trackingId: trackingId ?? this.trackingId,
      clienteId: clienteId ?? this.clienteId,
      choferId: choferId ?? this.choferId,
      estado: estado ?? this.estado,
      descripcion: descripcion ?? this.descripcion,
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    trackingId,
    clienteId,
    choferId,
    estado,
    descripcion,
    origen,
    destino,
    lastLat,
    lastLng,
    updatedAt,
  ];
}
