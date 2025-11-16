# Cómo Verificar el Tracking Automático

## Métodos para Verificar

### 1. **Indicador Visual en la App (Más Fácil)**

Cuando un chofer inicia sesión, verá una tarjeta azul en la parte superior que muestra:
- ✅ **Estado del tracking**: "Tracking automático activo" o "iniciando..."
- ⏱️ **Frecuencia configurada**: "Cada X minutos" (15, 30 o 60)
- 🕐 **Última actualización**: "Actualizado hace X minutos/segundos"

**Cómo verlo:**
1. Inicia sesión como chofer
2. Asegúrate de tener al menos un paquete asignado
3. Espera el intervalo configurado (15, 30 o 60 minutos)
4. La tarjeta se actualizará automáticamente mostrando la última actualización

---

### 2. **Verificar en Firestore (Más Detallado)**

#### A. Ver el campo `lastAutoUpdate` en el documento del paquete:

1. Ve a Firebase Console → Firestore
2. Abre la colección `packages`
3. Selecciona un paquete asignado al chofer
4. Busca el campo `lastAutoUpdate` (Timestamp)
5. Este campo se actualiza cada vez que el tracking automático envía la ubicación

#### B. Ver la subcolección `locations`:

1. En el mismo documento del paquete, abre la subcolección `locations`
2. Cada documento tiene:
   - `lat` y `lng`: coordenadas
   - `timestamp`: cuándo se registró
   - `source`: "auto" (indica que viene del tracking automático)

**Nota:** Los documentos con `source: "auto"` son los que vienen del tracking en segundo plano.

---

### 3. **Ver Logs en Android (Para Desarrolladores)**

Si tienes acceso a `adb logcat` o Android Studio:

```bash
adb logcat | grep "Tracking"
```

Verás mensajes como:
```
[Tracking] Ejecutando actualización automática a las 2025-01-16T10:30:00.000Z
[Tracking] Paquete abc123 actualizado: -12.1234, -77.5678
[Tracking] Actualización automática completada para 1 paquete(s)
```

---

### 4. **Verificar que Workmanager está Registrado**

En la app del chofer:
1. Abre la configuración de tracking (botón ⚙️ en el AppBar)
2. Verifica la frecuencia configurada
3. El tracking se inicia automáticamente cuando el chofer inicia sesión

---

## Requisitos para que Funcione

✅ **El chofer debe:**
- Estar logueado en la app
- Tener al menos un paquete asignado (`choferId` = su ID)
- Tener permisos de ubicación concedidos
- Tener el GPS activado

✅ **La app debe:**
- Estar instalada (no necesita estar abierta, pero puede estar en segundo plano)
- Tener conexión a internet cuando se ejecute el trabajo

---

## Solución de Problemas

### ❌ No se actualiza automáticamente

1. **Verifica permisos:**
   - Ve a Configuración del teléfono → Apps → Tu app → Permisos
   - Asegúrate de que "Ubicación" esté permitida (incluyendo "Permitir todo el tiempo" en Android 10+)

2. **Verifica que el chofer tenga paquetes asignados:**
   - En Firestore, busca en `packages` donde `choferId` = ID del chofer
   - Debe haber al menos un documento

3. **Verifica la frecuencia:**
   - El tracking puede tardar hasta el intervalo configurado (15, 30 o 60 minutos)
   - La primera actualización puede tardar hasta 1 minuto después de iniciar sesión

4. **Verifica la batería:**
   - Algunos dispositivos Android pueden pausar trabajos en segundo plano si la batería está optimizada
   - Ve a Configuración → Batería → Optimización de batería → Tu app → "No optimizar"

### ⚠️ Nota sobre Índices de Firestore

Si ves un error sobre un índice faltante al usar el indicador visual, necesitas crear un índice compuesto en Firestore:

- **Colección:** `packages`
- **Campos:**
  - `choferId` (Ascending)
  - `lastAutoUpdate` (Descending)

Firebase te mostrará un enlace para crearlo automáticamente cuando lo necesites.

---

## Frecuencias Disponibles

- **15 minutos**: Actualización frecuente (más consumo de batería/datos)
- **30 minutos**: Balance recomendado
- **60 minutos**: Actualización menos frecuente (ahorra batería/datos)

Puedes cambiar la frecuencia desde el botón ⚙️ en el AppBar cuando estás logueado como chofer.

