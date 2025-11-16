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

    for (final doc in packagesSnapshot.docs) {
      final packageId = doc.id;
      await firestore.collection('packages').doc(packageId).update({
        'lastLat': position.latitude,
        'lastLng': position.longitude,
        'estado': PackageStatus.enRuta.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await firestore
          .collection('packages')
          .doc(packageId)
          .collection('locations')
          .add({
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
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
    await Workmanager().registerPeriodicTask(
      trackingTaskName,
      trackingTaskName,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  Future<void> stop() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trackingUserId');
    await Workmanager().cancelByUniqueName(trackingTaskName);
  }
}

