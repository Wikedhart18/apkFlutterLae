# Roadmap de Desarrollo

## Estado actual
- Proyecto Flutter base creado con lutter create.
- Proyecto probado con lutter run (Chrome).
- Firebase configurado con FlutterFire CLI (pkrastreo-c6f87) y irebase_options.dart.
- Dependencias clave aÃ±adidas: Auth, Firestore, Messaging, Maps, Geolocator, Secure Storage, Bloc.

## PrÃ³ximos pasos inmediatos
1. Definir estructura feature-first (lib/src/...).
2. Implementar flujo Auth (login/registro/roles) usando Firebase Auth.
3. Crear capa de datos para paquetes y ubicaciones (Firestore/RTDB).
4. Agregar integraciÃ³n bÃ¡sica de geolocalizaciÃ³n (chofer) y mapa (cliente).
5. DiseÃ±ar UI inicial cliente vs chofer (pantallas de dashboard/resumen).
6. Configurar backend realtime (Firestore + Cloud Functions o Supabase) y plan del dashboard web.

## Futuras iteraciones
- Persistencia offline y reintentos en tracking.
- Alertas push y notificaciones segmentadas.
- Dashboard administrativo web.
- KPI y reportes para venta a clientes.
