# Roadmap de Desarrollo

## Estado actual
- Proyecto Flutter base creado con `flutter create` y probado en Web.
- Firebase configurado con FlutterFire CLI (`apkrastreo-c6f87`) y `firebase_options.dart`.
- Dependencias clave aÃ±adidas (Auth, Firestore, Messaging, Maps, Geolocator, Secure Storage, Bloc, Dartz).
- Arquitectura `lib/src` con mÃ³dulos `core`, `auth`, `tracking`, `packages` y `app.dart`.
- Repositorio de Auth (FirebaseAuth + Firestore) + `AuthBloc` operativos.
- Flujo de autenticaciÃ³n completo (AuthGate, Login, Register) + AppShell con saludo y logout.
- Capa de paquetes creada: entidad `Package`, repositorio Firebase y `PackageWatcherCubit` conectado a la UI con creaciÃ³n bÃ¡sica de paquetes.

## PrÃ³ximos pasos inmediatos
1. Pulir formularios de auth (reset password, feedback de errores especÃ­ficos).
2. Mejorar UX de paquetes (detalles, filtros por estado, asignaciÃ³n manual de choferes).
3. Integrar tracking en vivo: chofer comparte GPS (geolocator) y cliente ve stream (mapa Google o placeholder).
4. Definir flujo de asignaciones desde dashboard (admin reasigna camiones/phones).
5. Configurar notificaciones push (FCM) por cambio de estado y alertas.
6. Plan de backend complementario (Cloud Functions/Supabase) para lÃ³gica avanzada y validaciones.

## Futuras iteraciones
- Persistencia offline y reintentos en tracking.
- Alertas push y notificaciones segmentadas.
- Dashboard administrativo web.
- KPI y reportes para venta a clientes.
