# Roadmap de Desarrollo

## Estado actual
- Proyecto Flutter base creado con `flutter create` y probado en Web.
- Firebase configurado con FlutterFire CLI (`apkrastreo-c6f87`) y `firebase_options.dart`.
- Dependencias clave aÃ±adidas (Auth, Firestore, Messaging, Maps, Geolocator, Secure Storage, Bloc, Dartz).
- Arquitectura `lib/src` con mÃ³dulos `core`, `auth`, `tracking`, `packages` y `app.dart`.
- Repositorio de Auth (FirebaseAuth + Firestore) + `AuthBloc` creados.
- Pantallas Auth (`AuthGate`, `Login`, `Register`) conectadas al router, AppShell con saludo y logout.

## PrÃ³ximos pasos inmediatos
1. Estabilizar flujos de autenticaciÃ³n (validaciones adicionales, errores locales, reset). 
2. Crear capa de datos de paquetes (`packages/`) y endpoints Firestore/RTDB.
3. Implementar tracking en vivo: stream de ubicaciÃ³n chofer + listener en cliente.
4. DiseÃ±ar UI diferenciada cliente vs chofer (Home dashboards, lista de paquetes).
5. Configurar notificaciones push (FCM) y canales por paquete.
6. Planificar backend complementario (Cloud Functions/Supabase) para lÃ³gica avanzada.

## Futuras iteraciones
- Persistencia offline y reintentos en tracking.
- Alertas push y notificaciones segmentadas.
- Dashboard administrativo web.
- KPI y reportes para venta a clientes.
