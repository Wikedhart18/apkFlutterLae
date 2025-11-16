import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../firebase_options.dart';
import '../packages/domain/entities/package.dart';

// ignore: constant_identifier_names
const String trackingTaskName = 'trackpro_background_tracking';
const String _frequencyKey = 'tracking_frequency_minutes';

enum TrackingFrequency {
  seconds20(20), // Modo prueba: 20 segundos
  minutes15(15),
  minutes30(30),
  minutes60(60);

  const TrackingFrequency(this.seconds);
  final int seconds;

  // Para compatibilidad con código existente
  int get minutes => seconds ~/ 60;
  
  Duration get duration => Duration(seconds: seconds);
  
  String get displayName {
    if (seconds < 60) {
      return 'Cada $seconds segundos (prueba)';
    }
    return 'Cada ${minutes} minutos';
  }
}

Future<void> trackingCallbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    if (kIsWeb) return true;
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('trackingUserId');
    if (userId == null) {
      return true;
    }
    
    // Si es un one-off task de prueba, reprogramarlo después de ejecutar
    final isQuickTask = task.contains('_quick');
    int? frequencySeconds;
    if (isQuickTask && inputData != null) {
      frequencySeconds = inputData['frequencySeconds'] as int?;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return true;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return true;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final firestore = FirebaseFirestore.instance;
    final packagesSnapshot = await firestore
        .collection('packages')
        .where('choferId', isEqualTo: userId)
        .get();
    if (packagesSnapshot.docs.isEmpty) {
      return true;
    }

    final timestamp = DateTime.now();
    debugPrint('[Tracking] Ejecutando actualización automática a las ${timestamp.toIso8601String()}');
    
    for (final doc in packagesSnapshot.docs) {
      final packageId = doc.id;
      await firestore.collection('packages').doc(packageId).update({
        'lastLat': position.latitude,
        'lastLng': position.longitude,
        'estado': PackageStatus.enRuta.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastAutoUpdate': FieldValue.serverTimestamp(), // Marca para verificar tracking automático
      });
      await firestore
          .collection('packages')
          .doc(packageId)
          .collection('locations')
          .add({
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'source': 'auto', // Marca que viene del tracking automático
      });
      debugPrint('[Tracking] Paquete $packageId actualizado: ${position.latitude}, ${position.longitude}');
    }
    debugPrint('[Tracking] Actualización automática completada para ${packagesSnapshot.docs.length} paquete(s)');
    
    // Si es un one-off task de prueba, reprogramarlo
    if (isQuickTask && frequencySeconds != null) {
      await Workmanager().registerOneOffTask(
        '${trackingTaskName}_quick',
        '${trackingTaskName}_quick',
        initialDelay: Duration(seconds: frequencySeconds),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        inputData: {'frequencySeconds': frequencySeconds},
      );
      debugPrint('[Tracking] Reprogramado para ejecutarse en $frequencySeconds segundos');
    }
    
    return true;
  });
}

class BackgroundTrackingService {
  BackgroundTrackingService._();

  static final BackgroundTrackingService instance =
      BackgroundTrackingService._();

  Future<void> init() async {
    if (kIsWeb) return;
    await Workmanager().initialize(
      trackingCallbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  Future<void> start(String userId) async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trackingUserId', userId);
    
    // Obtener frecuencia guardada o usar 15 minutos por defecto
    final frequencySeconds = prefs.getInt(_frequencyKey) ?? 900; // 15 minutos = 900 segundos
    final frequency = Duration(seconds: frequencySeconds);
    
    // Workmanager tiene un mínimo de 15 minutos en producción
    // Para frecuencias menores (como 20 segundos en pruebas), usamos one-off tasks que se reprograman
    if (frequencySeconds < 900) { // Menos de 15 minutos
      // Para pruebas rápidas, usamos one-off task que se reprograma
      await Workmanager().registerOneOffTask(
        '${trackingTaskName}_quick',
        '${trackingTaskName}_quick',
        initialDelay: frequency,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        inputData: {'frequencySeconds': frequencySeconds},
      );
      debugPrint('[Tracking] Iniciado con frecuencia: $frequencySeconds segundos (MODO PRUEBA - One-off)');
    } else {
      // Para frecuencias normales (15+ minutos), usamos periodic task
      await Workmanager().registerPeriodicTask(
        trackingTaskName,
        trackingTaskName,
        frequency: frequency,
        initialDelay: const Duration(minutes: 1),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      debugPrint('[Tracking] Iniciado con frecuencia: ${frequencySeconds ~/ 60} minutos');
    }
  }

  Future<void> setFrequency(TrackingFrequency frequency) async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_frequencyKey, frequency.seconds);
    if (frequency.seconds < 60) {
      debugPrint('[Tracking] Frecuencia actualizada a: ${frequency.seconds} segundos (MODO PRUEBA)');
    } else {
      debugPrint('[Tracking] Frecuencia actualizada a: ${frequency.minutes} minutos');
    }
    
    // Si el tracking está activo, reiniciarlo con la nueva frecuencia
    final userId = prefs.getString('trackingUserId');
    if (userId != null) {
      await stop();
      await start(userId);
    }
  }

  Future<TrackingFrequency> getFrequency() async {
    if (kIsWeb) return TrackingFrequency.minutes15;
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_frequencyKey) ?? 900; // 15 minutos por defecto
    return TrackingFrequency.values.firstWhere(
      (f) => f.seconds == seconds,
      orElse: () => TrackingFrequency.minutes15,
    );
  }

  Future<void> stop() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trackingUserId');
    await Workmanager().cancelByUniqueName(trackingTaskName);
    await Workmanager().cancelByUniqueName('${trackingTaskName}_quick');
  }
}

