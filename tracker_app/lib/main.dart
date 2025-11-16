import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/tracking/background_tracking_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'src/notifications/push_notifications_service.dart';
import 'src/notifications/local_notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationsService.instance.initialize();
  await BackgroundTrackingService.instance.init();
  await PushNotificationsService.instance.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const TrackerApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Aquí podríamos registrar métricas o logs de mensajes recibidos en background.
}
