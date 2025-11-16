import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationsService {
  PushNotificationsService._();
  static final PushNotificationsService instance =
      PushNotificationsService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<String>? _onTokenRefreshSub;

  Future<void> init() async {
    if (kIsWeb) {
      // Web-push se configurará en una fase posterior (VAPID + service worker)
      return;
    }
    // iOS: pedir permisos de visualización si hace falta
    await _messaging.setAutoInitEnabled(true);
    // Suscribir refresh de token
    await _onTokenRefreshSub?.cancel();
    _onTokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] onTokenRefresh: $newToken');
      // No sabemos el userId aquí; se re-guardará al siguiente login o podemos
      // mantenerlo con un setter si hiciera falta.
    });
  }

  Future<void> requestPermissionAndRegisterToken(String userId) async {
    if (kIsWeb) return;

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(userId, token);
    }

    // Suscribir listeners de mensajes en foreground
    await _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      debugPrint('[FCM] onMessage: ${msg.notification?.title}');
      // Nota: para banner local podríamos integrar flutter_local_notifications más adelante
    });
    debugPrint('[FCM] token registrado para $userId: $token');
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onTokenRefreshSub?.cancel();
  }

  Future<void> _saveToken(String userId, String token) async {
    final ref =
        _firestore.collection('users').doc(userId).collection('fcmTokens');
    await ref.doc(token).set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': defaultTargetPlatform.name,
    }, SetOptions(merge: true));
  }
}

