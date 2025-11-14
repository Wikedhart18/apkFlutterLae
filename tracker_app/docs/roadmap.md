# Roadmap de Desarrollo

## Estado actual
- Proyecto Flutter base creado con `flutter create`.
- Proyecto probado con `flutter run` (Chrome).
- Firebase configurado con FlutterFire CLI (`apkrastreo-c6f87`) y `firebase_options.dart`.
- Dependencias clave aÃ±adidas: Auth, Firestore, Messaging, Maps, Geolocator, Secure Storage, Bloc.
- Se creÃ³ la estructura `lib/src` con mÃ³dulos `core`, `auth`, `tracking`, `packages` y un `app.dart` central.

## PrÃ³ximos pasos inmediatos
1. Implementar flujo Auth (login/registro/roles) usando Firebase Auth.
2. Crear capa de datos para paquetes y ubicaciones (Firestore/RTDB).
3. Agregar integraciÃ³n bÃ¡sica de geolocalizaciÃ³n (chofer) y mapa (cliente).
4. DiseÃ±ar UI inicial cliente vs chofer (pantallas de dashboard/resumen).
5. Configurar backend realtime (Firestore + Cloud Functions o Supabase) y plan del dashboard web.
6. Definir estrategia de despliegue/testing (QA interna + demo comercial).

## Futuras iteraciones
- Persistencia offline y reintentos en tracking.
- Alertas push y notificaciones segmentadas.
- Dashboard administrativo web.
- KPI y reportes para venta a clientes.
