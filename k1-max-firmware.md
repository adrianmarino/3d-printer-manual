# 🔄 Firmware y Actualizaciones de la Creality K1 Max

> **📌 Ver también:** [Configuración general](./k1-max-setup.md) — [Archivos de configuración y macros](./k1-max-config.md)

## Notas Importantes

### Actualizaciones de Firmware

> **⚠️ Cuidado:** Las actualizaciones de firmware de Creality **sobreescriben las configuraciones** pero **NO borran** Mainsail/Fluidd.

#### Versión actual vs disponible

> **📌 Importante:** La versión real del firmware se lee de `/etc/ota_info` (`ota_version`), **NO** del comentario `# Version:` en `printer.cfg` (que queda desactualizado tras cada actualización).

| Fuente | Versión | Estado |
| :--- | :--- | :--- |
| **Tu impresora (real)** | **V1.3.5.19** | ✅ Instalada (confirmado vía `/etc/ota_info`) |
| OTA sugerida | V1.3.5.22 | ⚠️ **NO instalar** — rompe cámara por LAN |
| Creality Website | V1.1.0.27 | Línea oficial separada |
| GitHub (K1_Series_Klipper) | V1.3.5.19 | Línea V1.3.x (tu firmware actual) |

#### Cronología de versiones (línea V1.3.x)

```
V1.3.3.5  (Ene 2024) — LiDAR, velocidad, modo experto, exclude objects
V1.3.3.46 (Dic 2024) — Fixes incrementales
V1.3.5.19 (2025)     ← TU VERSIÓN (estable, cámara OK)
V1.3.5.22 (Jul 2026) — ⚠️ Rompe cámara LAN (bug conocido)
```

> **⚠️ Bug conocido de V1.3.5.22:** "Optimize video stream transmission security" movió el stream a WebRTC y la cámara dejó de funcionar por LAN en K1/K1C/K1 Max. Usuarios recomiendan quedarse en V1.3.5.19 o hacer rollback. Fuente: [Foro Creality](https://forum.creality.com/t/new-k1c-firmware-v1-3-5-22-mono-color/52410)

#### Mejoras de la línea V1.3.x (vs firmware viejo v1.0.3)

| Función | Descripción |
| :--- | :--- |
| **AI LiDAR Flow Calibration** | Reconstruido para K1 Max, compatible con Creality Print, Prusa, Orca |
| **Ajuste de Velocidad** | 4 modos: Silent, Stable (50%), Standard (100%), Ultrafast (125%) |
| **Modo Experto** | Ajuste de flujo y offset Z durante impresión, calibración PID |
| **Exclude Objects** | Saltar objetos parciales en impresión por lotes |
| **Root oficial** | Soporte para instalar Mainsail/Fluidd desde el menú |
| **Ventilador de chasis** | Controlado por temperatura de cámara (35°C) en vez de siempre encendido |

#### Proceso de actualización seguro

**Paso 1: Backup completo**
```bash
# Ejecutar desde la máquina local (NO desde la impresora)
./scripts/backup-k1-max.sh
```

El script crea un backup en `~/k1-max-backups/<timestamp>/` con:
- Todas las configuraciones (`printer.cfg`, `gcode_macro.cfg`, etc.)
- Configuraciones de addons (KAMP, timelapse, M600)
- Moonraker, OctoEverywhere
- Metadata de versiones y servicios

**Paso 2: Descargar firmware**
```bash
# Descargar desde:
# https://www.creality.com/download/creality-k1-max-3d-printer

# Copiar archivo .bin a USB formateado en FAT32
```

**Paso 3: Instalar firmware**
1. Apagar la impresora
2. Insertar USB con el archivo `.bin`
3. Encender la impresora
4. Menú → Sistema → Actualizar → Seleccionar archivo
5. Esperar a que termine (no apagar)

**Paso 4: Restaurar configuraciones**
```bash
# Ejecutar desde la máquina local
./scripts/restore-k1-max.sh ~/k1-max-backups/<timestamp>
```

El script:
- Restaura todas las configuraciones
- Reinstala Helper-Script si fue eliminado
- Verifica integridad de archivos
- Genera reporte de diferencias
- Reinicia Klipper

**Paso 5: Verificar**
1. Abrir Mainsail: `http://192.168.2.100`
2. Verificar que los ejes se mueven correctamente
3. Imprimir una pieza de prueba

#### Scripts de backup/restore

| Script | Descripción |
| :--- | :--- |
| `scripts/backup-k1-max.sh` | Backup completo antes de actualizar |
| `scripts/restore-k1-max.sh` | Restaurar después de actualizar |

```bash
# Backup
./scripts/backup-k1-max.sh

# Restore
./scripts/restore-k1-max.sh ~/k1-max-backups/20260808_110020
```

### Espacio en Disco

El sistema tiene **6.5GB** en `/usr/data` con **3.9GB** usados y **2.2GB** libres. Mantener al menos **1GB libre** para evitar problemas.

### Actualización de Klipper

El Klipper instalado es la versión de **Creality** (V1.3.5.19, corre en Python 3.8.2 vía el venv `klippy-env`). Si se quiere instalar Klipper mainline, se necesita usar un mod como [ballaswag/creality_k1_klipper_mod](https://github.com/ballaswag/creality_k1_klipper_mod).

> **Nota:** El mod de ballaswag **elimina el LiDAR** y los servicios de Creality. Si quieres mantener el LiDAR, usa la actualización oficial de Creality.

### Cómo verificar la versión real del firmware

```bash
# Conectarse por SSH
ssh-k1-max

# Leer la versión real (no el comentario en printer.cfg)
cat /etc/ota_info | grep ota_version
# → ota_version=1.3.5.19

# Alternativa con el script oficial
sh /etc/ota_bin/get_ota_current_version.sh
# → 1.3.5.19
```
