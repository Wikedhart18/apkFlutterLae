# Roadmap de Desarrollo

## Estado actual
- Proyecto Flutter base creado con `flutter create` y probado en Web.
- Firebase configurado con FlutterFire CLI (`apkrastreo-c6f87`) y `firebase_options.dart`.
- Dependencias clave añadidas (Auth, Firestore, Messaging, Maps, Geolocator, Secure Storage, Bloc, Dartz).
- Arquitectura `lib/src` con módulos `core`, `auth`, `tracking`, `packages` y `app.dart`.
- Repositorio de Auth (FirebaseAuth + Firestore) + `AuthBloc` operativos.
- Flujo de autenticación completo (AuthGate, Login, Register) + AppShell con saludo y logout.
- Capa de paquetes creada: entidad `Package`, repositorio Firebase y `PackageWatcherCubit` conectado a la UI con creación básica de paquetes.
- Dashboards iniciales: admin puede asignar clientes/choferes, cambiar estados y cada rol ve sólo sus paquetes.
- Chofer puede compartir ubicación actual, guardar historial (subcolección `locations`) y los clientes ven la ruta en un mapa a pantalla completa.
- Tracking en segundo plano configurado con `workmanager` para choferes.
- Cliente FCM configurado para Android/iOS (permisos, token en Firestore, handlers).
- Microservicio de notificaciones en Render funcionando: webhook automático desde la app cuando se crea/asigna/cambia estado de paquetes.
- Notificaciones push funcionando end-to-end: cliente recibe notificaciones cuando hay cambios de estado.
- Notificaciones locales en foreground: integrado `flutter_local_notifications` para mostrar banner cuando la app está abierta.
- Controles de frecuencia para tracking: choferes pueden ajustar intervalo (15min, 30min, 1h) desde la UI.
- Pull-to-refresh en lista de paquetes para recargar datos manualmente.

## Próximos pasos inmediatos
1. Web Push: añadir VAPID + `web/firebase-messaging-sw.js` para notificaciones en navegadores.
2. Probar Workmanager en iOS (requiere Xcode + configuración BGTask).
3. Añadir más triggers (p. ej., cuando un chofer se aproxima al destino).
4. Mejorar feedback visual: indicadores de carga más claros, animaciones de transición.

## Futuras iteraciones
- Persistencia offline y reintentos en tracking.
- Alertas push y notificaciones segmentadas.
- Dashboard administrativo web.
- KPI y reportes para venta a clientes.
