# 🖥️ Configuración de la Creality K1 Max

Documentación de la configuración actual de la impresora 3D Creality K1 Max de este repositorio.

## Especificaciones de Hardware

| Componente | Detalle |
| :--- | :--- |
| **Modelo** | Creality K1 Max |
| **Volumen de impresión** | 300 x 300 x 300 mm |
| **MCU Principal** | GD32F303RET6 (CR4CU220812S12) |
| **MCU Boquilla** | GD32F303CBT6 (K1-NOZZLE-M_V12) |
| **MCU Leveling** | GD32E230F8P6 (K1-MAX-L-V11) |
| **Conectividad** | WiFi, Ethernet, USB |

## Sistema Operativo

| Componente | Versión |
| :--- | :--- |
| **Sistema** | Buildroot 2020.02.1 |
| **Firmware** | **V1.3.5.19** (ver `/etc/ota_info`) |
| **Kernel** | Linux 4.4.94 (mips, compilado Nov 2025) |
| **Python** | 3.8.2 (venv `klippy-env`, para Klipper) |
| **Almacenamiento** | 6.5GB (3.9GB usado, 2.2GB libre en `/usr/data`) |

## Software Instalado

### Core (Stack de Impresión)

| Software | Versión | Puerto | Descripción |
| :--- | :--- | :--- | :--- |
| **Klipper** | Creality V1.3.5.19 (Python 3.8.2) | - | Firmware de impresión 3D |
| **Moonraker** | - | - | API server para Klipper |
| **Mainsail** | v2.17.0 | 4408 | Interfaz web para controlar la impresora |

### Addons Instalados

| Addon | Descripción |
| :--- | :--- |
| **OctoEverywhere** | Acceso remoto a la impresora desde cualquier lugar |
| **KAMP** | Klipper Adaptive Meshing & Purging (malla adaptativa) |
| **Timelapse** | Macros para crear videos timelapse de impresiones |
| **M600 Support** | Soporte para cambio de filamento (M600) |

### Configuración de Red

| Servicio | Puerto |
| :--- | :--- |
| **Mainsail (Nginx)** | 4408 |
| **Moonraker** | 7125 (interno) |
| **SSH** | 22 |

## Archivos de Configuración

```
/usr/data/printer_data/config/
├── printer.cfg              # Configuración principal
├── gcode_macro.cfg          # Macros GCode (HEATSOAK_CHAMBER, etc.)
├── printer_params.cfg       # Parámetros de la impresora
├── sensorless.cfg           # Configuración de homing sensorless
└── Helper-Script/
    ├── timelapse.cfg        # Macros de timelapse
    ├── M600-support.cfg     # Soporte de cambio de filamento
    └── KAMP/
        └── KAMP_Settings.cfg # Configuración de KAMP
```

## Macros Personalizados

### HEATSOAK_CHAMBER

Macro de calentamiento inteligente de cámara para ABS.

```gcode
HEATSOAK_CHAMBER BED_TEMP=100 CHAMBER_TARGET=55 TIMEOUT=40
```

- **Parámetros:** `BED_TEMP` (default 100), `CHAMBER_TARGET` (default 50), `TIMEOUT` en minutos (default 40)
- **Cancelación:** `HEATSOAK_CHAMBER_CANCEL`
- **Protecciones:** Timeout, límite de ciclos (400), verificación de posición Z

### Otros Macros

- `xyz_ready` — Control de home para ejes
- `T0` — Definición de herramienta (nula para evitar errores)
- Macros de KAMP para malla adaptativa
- Macros de timelapse para grabación automática

## Conexión SSH

```bash
# Alias definido en .zshrc
alias ssh-k1-max='ssh root@192.168.2.100 -p 22'

# Conexión directa
ssh root@192.168.2.100

# Password: creality_2023
```

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

## Instalación de Addons

Para instalar o gestionar addons, se recomienda usar el [Installation Helper Script de Guilouz](https://github.com/Guilouz/Creality-K1-and-K1-Max/wiki):

```bash
# Conectarse por SSH
ssh-k1-max

# Ejecutar el script instalador
wget --no-check-certificate -O - https://raw.githubusercontent.com/Guilouz/Creality-K1-and-K1-Max/main/Scripts/installer.sh | bash
```
