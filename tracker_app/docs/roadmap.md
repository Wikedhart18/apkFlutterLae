# Roadmap de Desarrollo

## Estado actual
- Proyecto Flutter base creado con `flutter create` y probado en Web.
- Firebase configurado con FlutterFire CLI (`apkrastreo-c6f87`) y `firebase_options.dart`.
- Dependencias clave aÃ±adidas (Auth, Firestore, Messaging, Maps, Geolocator, Secure Storage, Bloc, Dartz).
- Arquitectura `lib/src` con mÃ³dulos `core`, `auth`, `tracking`, `packages` y `app.dart`.
- Repositorio de Auth (FirebaseAuth + Firestore) + `AuthBloc` operativos.
- Flujo de autenticaciÃ³n completo (AuthGate, Login, Register) + AppShell con saludo y logout.
- Capa de paquetes creada: entidad `Package`, repositorio Firebase y `PackageWatcherCubit` conectado a la UI con creaciÃ³n bÃ¡sica de paquetes.
- Dashboards iniciales: admin puede asignar clientes/choferes, cambiar estados y cada rol ve sÃ³lo sus paquetes.
- Chofer puede compartir ubicaciÃ³n actual usando Geolocator (actualiza `lastLat/lastLng`).

## PrÃ³ximos pasos inmediatos
1. Pulir formularios de auth (reset password, feedback de errores especÃ­ficos).
2. Mejorar detalle de paquetes (timeline, mapa con `google_maps_flutter`, filtros por estado/rol).
3. Persistencia del tracking: historial de posiciones, intervalos automÃ¡ticos y soporte background en Android/iOS.
4. Configurar notificaciones push (FCM) por cambio de estado y alertas.
5. Plan de backend complementario (Cloud Functions/Supabase) para lÃ³gica avanzada y reportes/KPI.

## Futuras iteraciones
- Persistencia offline y reintentos en tracking.
- Alertas push y notificaciones segmentadas.
- Dashboard administrativo web.
- KPI y reportes para venta a clientes.
