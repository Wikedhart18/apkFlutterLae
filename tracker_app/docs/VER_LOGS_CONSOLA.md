# Cómo Ver los Logs desde la Consola

## Método 1: ADB Logcat (Recomendado)

### Requisitos
- Android Debug Bridge (ADB) instalado
- Teléfono conectado por USB con depuración USB activada
- O emulador Android ejecutándose

### Pasos

1. **Conecta tu dispositivo o inicia el emulador**

2. **Abre PowerShell o CMD en Windows**

3. **Verifica que el dispositivo esté conectado:**
```powershell
adb devices
```
Deberías ver algo como:
```
List of devices attached
ABC123XYZ    device
```

4. **Ver todos los logs de la app:**
```powershell
adb logcat | Select-String "tracker_app"
```

5. **Ver solo los logs de tracking (más específico):**
```powershell
adb logcat | Select-String "Tracking"
```

6. **Ver logs en tiempo real con filtro:**
```powershell
adb logcat -s flutter:V Tracking:* *:S
```
Esto muestra:
- Todos los logs de Flutter (`flutter:V`)
- Todos los logs que contengan "Tracking" (`Tracking:*`)
- Suprime el resto (`*:S`)

7. **Guardar logs en un archivo:**
```powershell
adb logcat | Select-String "Tracking" > tracking_logs.txt
```

---

## Método 2: Android Studio

1. **Abre Android Studio**

2. **Conecta tu dispositivo o inicia el emulador**

3. **Ve a la pestaña "Logcat"** (abajo de la pantalla)

4. **Filtra por:**
   - **Tag:** `Tracking` o `flutter`
   - **Package:** `com.example.tracker_app` (o el nombre de tu paquete)

5. **Los logs aparecerán en tiempo real**

---

## Método 3: Flutter Run (Terminal)

Si ejecutas la app con `flutter run`, los logs aparecen directamente en la terminal:

```powershell
cd tracker_app
flutter run
```

Verás todos los `debugPrint` y `print` en la consola.

---

## Logs Importantes a Buscar

### Cuando el tracking se inicia:
```
[Tracking] Iniciado con frecuencia: 20 segundos (MODO PRUEBA)
```

### Cuando se ejecuta el tracking automático:
```
[Tracking] Ejecutando actualización automática a las 2025-01-16T10:30:00.000Z
[Tracking] Paquete abc123 actualizado: -12.1234, -77.5678
[Tracking] Actualización automática completada para 1 paquete(s)
```

### Cuando cambias la frecuencia:
```
[Tracking] Frecuencia actualizada a: 20 segundos (MODO PRUEBA)
```

### Errores comunes:
```
[Tracking] GPS no habilitado
[Tracking] Permisos de ubicación denegados
```

---

## Comandos Útiles

### Limpiar logs anteriores:
```powershell
adb logcat -c
```

### Ver solo errores:
```powershell
adb logcat *:E
```

### Ver logs de una app específica:
```powershell
adb logcat | Select-String "com.example.tracker_app"
```

### Ver logs con timestamp:
```powershell
adb logcat -v time | Select-String "Tracking"
```

---

## Nota sobre Frecuencias de Prueba (20 segundos)

✅ **Modo Prueba Activado:**
- La opción de **20 segundos** está disponible para pruebas rápidas
- Usa `one-off tasks` que se reprograman automáticamente
- Funciona tanto en modo debug como en release
- **Ideal para verificar que el tracking funciona correctamente**

⚠️ **Limitaciones de Workmanager:**
- Para frecuencias de **15 minutos o más**, usa `periodic tasks` (más eficiente)
- Para frecuencias menores (como 20 segundos), usa `one-off tasks` que se reprograman
- El sistema puede tener pequeñas variaciones de tiempo (±2-5 segundos)

💡 **Recomendación:** Usa 20 segundos solo para pruebas. En producción, usa 15, 30 o 60 minutos para ahorrar batería y datos.

---

## Troubleshooting

### No veo logs:
1. Verifica que el dispositivo esté conectado: `adb devices`
2. Asegúrate de que la app esté ejecutándose
3. Verifica que tengas permisos de depuración USB activados en el teléfono

### Los logs no aparecen en tiempo real:
- Usa `adb logcat -c` para limpiar y luego vuelve a filtrar
- Asegúrate de que la app esté en modo debug (no release)

### No veo los logs de tracking:
- Verifica que el chofer esté logueado
- Verifica que tenga paquetes asignados
- Espera el intervalo configurado (20 segundos en modo prueba)

