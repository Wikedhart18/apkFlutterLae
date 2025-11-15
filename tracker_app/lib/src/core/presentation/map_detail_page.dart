import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../packages/domain/entities/location_point.dart';
import '../../packages/domain/entities/package.dart';
import '../../packages/domain/repositories/package_repository.dart';

class MapDetailPage extends StatelessWidget {
  const MapDetailPage({super.key, required this.package});

  final Package package;

  bool get _hasLocation => package.lastLat != null && package.lastLng != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ruta: ${package.trackingId}')),
      body: _hasLocation
          ? _MapContent(package: package)
          : const Center(child: Text('Aún no hay ubicación registrada')),
    );
  }
}

class _MapContent extends StatelessWidget {
  const _MapContent({required this.package});

  final Package package;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PackageRepository>();
    final initial = LatLng(package.lastLat!, package.lastLng!);

    return StreamBuilder<List<LocationPoint>>(
      stream: repo.watchLocationHistory(package.id),
      builder: (context, snapshot) {
        final points = snapshot.data ?? [];
        final polyline = points.map((p) => LatLng(p.lat, p.lng)).toList();
        final currentPoint = polyline.isNotEmpty ? polyline.last : initial;
        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: currentPoint,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.tracker_app',
                  ),
                  if (polyline.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: polyline,
                          color: Colors.indigo,
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentPoint,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Estado: ${package.estado.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (package.destino != null)
                    Text('Destino: ${package.destino}'),
                  const SizedBox(height: 8),
                  Text(
                    'Última actualización: ${package.updatedAt ?? DateTime.now()}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coordenadas actuales: '
                    '${currentPoint.latitude.toStringAsFixed(4)}, '
                    '${currentPoint.longitude.toStringAsFixed(4)}',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
