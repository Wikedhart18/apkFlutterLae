import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../auth/domain/entities/app_user.dart';
import '../../auth/domain/repositories/user_repository.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../packages/domain/entities/location_point.dart';
import '../../packages/domain/entities/package.dart';
import '../../packages/domain/repositories/package_repository.dart';
import '../../packages/presentation/cubit/package_watcher_cubit.dart';
import '../navigation/app_router.dart';
import '../../tracking/background_tracking_service.dart';
import '../../notifications/push_notifications_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthBloc>().state.user;
      context.read<PackageWatcherCubit>().watchForUser(user);
      // Inicializar subscripción de FCM en arranque si ya hay sesión
      if (user != null) {
        PushNotificationsService.instance.requestPermissionAndRegisterToken(
          user.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.user != current.user,
      listener: (context, state) {
        context.read<PackageWatcherCubit>().watchForUser(state.user);
        final trackingService = BackgroundTrackingService.instance;
        final user = state.user;
        if (user != null && user.isChofer) {
          trackingService.start(user.id);
        } else {
          trackingService.stop();
        }
        final push = PushNotificationsService.instance;
        if (user != null) {
          push.requestPermissionAndRegisterToken(user.id);
        } else {
          push.dispose();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TrackPro LAE MVP v1.0.0'),
          actions: [
            if (user != null && user.isChofer)
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Configurar frecuencia de tracking',
                onPressed: () => _showTrackingFrequencyDialog(context),
              ),
            if (user != null)
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthSignOutRequested()),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (user != null && user.isChofer) ...[
                _TrackingStatusIndicator(userId: user.id),
                const SizedBox(height: 12),
              ],
              Expanded(child: _PackagesBody(user: user)),
            ],
          ),
        ),
        floatingActionButton: (user != null && (user.isAdmin || !user.isChofer))
            ? FloatingActionButton.extended(
                onPressed: () => _showCreatePackageDialog(context, user),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo paquete'),
              )
            : null,
      ),
    );
  }

  Future<void> _showCreatePackageDialog(
    BuildContext context,
    AppUser user,
  ) async {
    final trackingController = TextEditingController();
    final descripcionController = TextEditingController();
    final destinoController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final repo = context.read<PackageRepository>();
    final userRepo = context.read<UserRepository>();

    List<AppUser> clientes = [user];
    List<AppUser> choferes = [];
    AppUser? selectedCliente = user;
    AppUser? selectedChofer;

    if (user.isAdmin) {
      final clientsResult = await userRepo.fetchUsersByRole(UserRole.cliente);
      clientsResult.fold(
        (error) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error))),
        (list) => clientes = list,
      );
      if (clientes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay clientes registrados para asignar.'),
          ),
        );
        return;
      }
      selectedCliente = clientes.first;

      final driversResult = await userRepo.fetchUsersByRole(UserRole.chofer);
      driversResult.fold((_) {}, (list) => choferes = list);
      if (choferes.isNotEmpty) {
        selectedChofer = choferes.first;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Crear paquete'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: trackingController,
                        decoration: const InputDecoration(
                          labelText: 'Tracking ID',
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: destinoController,
                        decoration: const InputDecoration(labelText: 'Destino'),
                      ),
                      if (user.isAdmin) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<AppUser>(
                          value: selectedCliente,
                          decoration: const InputDecoration(
                            labelText: 'Cliente',
                          ),
                          items: clientes
                              .map(
                                (c) => DropdownMenuItem<AppUser>(
                                  value: c,
                                  child: Text(c.displayName ?? c.email),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedCliente = value),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<AppUser?>(
                          value: selectedChofer,
                          decoration: const InputDecoration(
                            labelText: 'Asignar chofer (opcional)',
                          ),
                          items: [
                            const DropdownMenuItem<AppUser?>(
                              value: null,
                              child: Text('Sin asignar'),
                            ),
                            ...choferes.map(
                              (driver) => DropdownMenuItem<AppUser?>(
                                value: driver,
                                child: Text(driver.displayName ?? driver.email),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => selectedChofer = value),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final clienteSeleccionado = selectedCliente ?? user;
                    final result = await repo.createPackage(
                      trackingId: trackingController.text.trim(),
                      clienteId: clienteSeleccionado.id,
                      descripcion: descripcionController.text.trim(),
                      destino: destinoController.text.trim(),
                      choferId: selectedChofer?.id,
                    );
                    result.fold(
                      (error) => ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error))),
                      (_) => Navigator.of(ctx).pop(),
                    );
                  },
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showTrackingFrequencyDialog(BuildContext context) async {
    final trackingService = BackgroundTrackingService.instance;
    final currentFrequency = await trackingService.getFrequency();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          TrackingFrequency selected = currentFrequency;
          return AlertDialog(
            title: const Text('Frecuencia de tracking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: TrackingFrequency.values.map((freq) {
                return RadioListTile<TrackingFrequency>(
                  title: Text(freq.displayName),
                  value: freq,
                  groupValue: selected,
                  onChanged: (value) {
                    setState(() => selected = value!);
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  await trackingService.setFrequency(selected);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Frecuencia actualizada: ${selected.displayName}',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrackingStatusIndicator extends StatefulWidget {
  const _TrackingStatusIndicator({required this.userId});

  final String userId;

  @override
  State<_TrackingStatusIndicator> createState() =>
      _TrackingStatusIndicatorState();
}

class _TrackingStatusIndicatorState extends State<_TrackingStatusIndicator> {
  TrackingFrequency? _frequency;
  DateTime? _lastAutoUpdate;

  @override
  void initState() {
    super.initState();
    _loadFrequency();
    _watchLastUpdate();
  }

  Future<void> _loadFrequency() async {
    final freq = await BackgroundTrackingService.instance.getFrequency();
    if (mounted) {
      setState(() => _frequency = freq);
    }
  }

  void _watchLastUpdate() {
    // Escuchar el último paquete asignado para ver cuándo fue la última actualización automática
    FirebaseFirestore.instance
        .collection('packages')
        .where('choferId', isEqualTo: widget.userId)
        .orderBy('lastAutoUpdate', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final data = snapshot.docs.first.data();
            final timestamp = data['lastAutoUpdate'] as Timestamp?;
            if (timestamp != null && mounted) {
              setState(() => _lastAutoUpdate = timestamp.toDate());
            }
          }
        });
  }

  String _formatLastUpdate() {
    if (_lastAutoUpdate == null)
      return 'Aún no hay actualizaciones automáticas';
    final now = DateTime.now();
    final diff = now.difference(_lastAutoUpdate!);
    if (diff.inMinutes < 1) {
      return 'Actualizado hace ${diff.inSeconds} segundos';
    } else if (diff.inHours < 1) {
      return 'Actualizado hace ${diff.inMinutes} minutos';
    } else {
      return 'Actualizado hace ${diff.inHours} horas';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: _lastAutoUpdate != null ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tracking automático ${_lastAutoUpdate != null ? "activo" : "iniciando..."}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _frequency != null
                        ? 'Frecuencia: ${_frequency!.displayName}'
                        : 'Cargando...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_lastAutoUpdate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatLastUpdate(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagesBody extends StatelessWidget {
  const _PackagesBody({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Inicia sesión para ver tus paquetes'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.login);
              },
              child: const Text('Ir a iniciar sesión'),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<PackageWatcherCubit, PackageWatcherState>(
      builder: (context, state) {
        switch (state.status) {
          case PackageWatcherStatus.initial:
            return const Center(child: Text('Cargando paquetes...'));
          case PackageWatcherStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case PackageWatcherStatus.failure:
            return Center(
              child: Text(state.message ?? 'Error cargando paquetes'),
            );
          case PackageWatcherStatus.success:
            if (state.packages.isEmpty) {
              return Center(
                child: Text(
                  user!.isChofer
                      ? 'No tienes entregas asignadas'
                      : 'Aún no tienes paquetes',
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                // Forzar recarga de paquetes
                context.read<PackageWatcherCubit>().watchForUser(user);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.separated(
                itemCount: state.packages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pkg = state.packages[index];
                  return _PackageCard(package: pkg, currentUser: user!);
                },
              ),
            );
        }
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.currentUser});

  final Package package;
  final AppUser currentUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => _showPackageDetail(context, currentUser, package),
        title: Text('Tracking: ${package.trackingId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${package.estado.name}'),
            if (package.destino != null) Text('Destino: ${package.destino}'),
            if (package.lastLat != null && package.lastLng != null)
              Text(
                'Última posición: ${package.lastLat!.toStringAsFixed(4)}, '
                '${package.lastLng!.toStringAsFixed(4)}',
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

Future<void> _showPackageDetail(
  BuildContext context,
  AppUser user,
  Package package,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _PackageDetailSheet(user: user, package: package),
    ),
  );
}

class _PackageDetailSheet extends StatefulWidget {
  const _PackageDetailSheet({required this.user, required this.package});

  final AppUser user;
  final Package package;

  @override
  State<_PackageDetailSheet> createState() => _PackageDetailSheetState();
}

class _PackageDetailSheetState extends State<_PackageDetailSheet> {
  late PackageStatus _status = widget.package.estado;
  AppUser? _selectedDriver;
  List<AppUser> _drivers = [];
  bool _loadingDrivers = false;
  bool _saving = false;
  bool _updatingLocation = false;
  String? _error;

  bool get _canUpdateStatus => widget.user.isAdmin || widget.user.isChofer;
  bool get _canAssignDriver => widget.user.isAdmin;
  bool get _canSendLocation =>
      widget.user.isChofer && widget.package.choferId == widget.user.id;

  @override
  void initState() {
    super.initState();
    if (_canAssignDriver) {
      _loadDrivers();
    }
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _loadingDrivers = true;
    });
    final result = await context.read<UserRepository>().fetchUsersByRole(
      UserRole.chofer,
    );
    result.fold((error) => setState(() => _error = error), (drivers) {
      AppUser? selected;
      for (final driver in drivers) {
        if (driver.id == widget.package.choferId) {
          selected = driver;
          break;
        }
      }
      setState(() {
        _drivers = drivers;
        _selectedDriver = selected;
        _error = null;
      });
    });
    setState(() {
      _loadingDrivers = false;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    final repo = context.read<PackageRepository>();
    String? message;

    if (_status != widget.package.estado) {
      final result = await repo.updateStatus(
        packageId: widget.package.id,
        status: _status,
      );
      result.fold(
        (error) => message = error,
        (_) => message = 'Estado actualizado',
      );
    }

    if (_canAssignDriver && _selectedDriver?.id != widget.package.choferId) {
      final result = await repo.assignDriver(
        packageId: widget.package.id,
        choferId: _selectedDriver?.id,
      );
      result.fold(
        (error) => message = error,
        (_) => message = 'Chofer asignado',
      );
    }

    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message!)));
    }

    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _sendCurrentLocation() async {
    setState(() => _updatingLocation = true);
    final repo = context.read<PackageRepository>();
    String? message;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        message = 'Activa el GPS del dispositivo';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        message = 'Permisos de ubicación denegados';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final result = await repo.updateLocation(
        packageId: widget.package.id,
        lat: position.latitude,
        lng: position.longitude,
      );
      result.fold(
        (error) => message = error,
        (_) => message = 'Ubicación enviada',
      );
    } catch (e) {
      message = 'No se pudo obtener la ubicación';
    } finally {
      setState(() => _updatingLocation = false);
      if (message != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paquete ${widget.package.trackingId}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.map_outlined),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.mapDetail,
                        arguments: widget.package,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Cliente: ${widget.package.clienteId}'),
          Text('Chofer: ${widget.package.choferId ?? 'Sin asignar'}'),
          if (widget.package.destino != null)
            Text('Destino: ${widget.package.destino}'),
          const SizedBox(height: 12),
          _StatusTimeline(current: _status),
          const SizedBox(height: 12),
          _MapPreview(package: widget.package),
          const SizedBox(height: 16),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          if (_canUpdateStatus)
            DropdownButtonFormField<PackageStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: PackageStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
          const SizedBox(height: 12),
          if (_canAssignDriver)
            _loadingDrivers
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<AppUser?>(
                    value: _selectedDriver,
                    decoration: const InputDecoration(
                      labelText: 'Chofer asignado',
                    ),
                    items: [
                      const DropdownMenuItem<AppUser?>(
                        value: null,
                        child: Text('Sin asignar'),
                      ),
                      ..._drivers.map(
                        (driver) => DropdownMenuItem<AppUser?>(
                          value: driver,
                          child: Text(driver.displayName ?? driver.email),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() {
                      _selectedDriver = value;
                    }),
                  ),
          const SizedBox(height: 16),
          if (_canSendLocation)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.icon(
                onPressed: _updatingLocation ? null : _sendCurrentLocation,
                icon: _updatingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Compartir ubicación'),
              ),
            ),
          FilledButton.icon(
            onPressed: _saving ? null : _saveChanges,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Guardar cambios'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.current});

  final PackageStatus current;

  @override
  Widget build(BuildContext context) {
    final statuses = PackageStatus.values;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: statuses
          .map(
            (status) => Chip(
              avatar: Icon(
                Icons.circle,
                size: 14,
                color: status.index <= current.index
                    ? Colors.green
                    : Colors.grey.shade400,
              ),
              label: Text(status.name),
              backgroundColor: status.index <= current.index
                  ? Colors.green.shade50
                  : Colors.grey.shade200,
            ),
          )
          .toList(),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.package});

  final Package package;

  bool get _hasLocation => package.lastLat != null && package.lastLng != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasLocation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          'Aún no hay ubicación registrada',
          textAlign: TextAlign.center,
        ),
      );
    }

    final center = LatLng(package.lastLat!, package.lastLng!);
    final repo = context.read<PackageRepository>();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 220,
        child: StreamBuilder<List<LocationPoint>>(
          stream: repo.watchLocationHistory(package.id),
          builder: (context, snapshot) {
            final points = snapshot.data ?? [];
            final polyline = points
                .map((point) => LatLng(point.lat, point.lng))
                .toList();
            final lastPoint = polyline.isNotEmpty ? polyline.last : center;
            return FlutterMap(
              options: MapOptions(initialCenter: lastPoint, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.tracker_app',
                ),
                if (polyline.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polyline,
                        strokeWidth: 4,
                        color: Colors.indigo,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: lastPoint,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
