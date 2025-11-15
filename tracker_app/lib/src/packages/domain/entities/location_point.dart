import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  const LocationPoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  final double lat;
  final double lng;
  final DateTime timestamp;

  @override
  List<Object> get props => [lat, lng, timestamp];
}

