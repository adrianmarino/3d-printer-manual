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
| **Kernel** | Linux 4.4.94 (mips) |
| **Python** | 2.7 (para Klipper) |
| **Almacenamiento** | 6.5GB (2.2GB usado en `/usr/data`) |

## Software Instalado

### Core (Stack de Impresión)

| Software | Versión | Puerto | Descripción |
| :--- | :--- | :--- | :--- |
| **Klipper** | Creality (Python 2) | - | Firmware de impresión 3D |
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

**Antes de actualizar:**
```bash
# Conectarse por SSH
ssh-k1-max

# Copiar configuraciones
cp -r /usr/data/printer_data/config ~/config_backup
cp /usr/data/printer_data/config/printer.cfg ~/printer.cfg.backup
```

### Espacio en Disco

El sistema tiene **6.5GB** en `/usr/data` con **2.2GB** usados. Mantener al menos **1GB libre** para evitar problemas.

### Actualización de Klipper

El Klipper instalado es la versión de **Creality** (basada en Python 2). Si se quiere instalar Klipper mainline (Python 3), se necesita usar un mod como [ballaswag/creality_k1_klipper_mod](https://github.com/ballaswag/creality_k1_klipper_mod).

## Instalación de Addons

Para instalar o gestionar addons, se recomienda usar el [Installation Helper Script de Guilouz](https://github.com/Guilouz/Creality-K1-and-K1-Max/wiki):

```bash
# Conectarse por SSH
ssh-k1-max

# Ejecutar el script instalador
wget --no-check-certificate -O - https://raw.githubusercontent.com/Guilouz/Creality-K1-and-K1-Max/main/Scripts/installer.sh | bash
```
