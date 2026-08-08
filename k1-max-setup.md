# 🖥️ Configuración de la Creality K1 Max

Documentación de la configuración actual de la impresora 3D Creality K1 Max de este repositorio.

> **📌 Índice de temas relacionados:**
> - [Firmware y actualizaciones](./k1-max-firmware.md) — versiones, OTA, backup/restore
> - [Archivos de configuración y macros](./k1-max-config.md) — printer.cfg, HEATSOAK_CHAMBER

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
| **Firmware** | **V1.3.5.19** (ver [k1-max-firmware.md](./k1-max-firmware.md)) |
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

## Conexión SSH

```bash
# Alias definido en .zshrc
alias ssh-k1-max='ssh root@192.168.2.100 -p 22'

# Conexión directa
ssh root@192.168.2.100

# Password: creality_2023
```

## Instalación de Addons

Para instalar o gestionar addons, se recomienda usar el [Installation Helper Script de Guilouz](https://github.com/Guilouz/Creality-K1-and-K1-Max/wiki):

```bash
# Conectarse por SSH
ssh-k1-max

# Ejecutar el script instalador
wget --no-check-certificate -O - https://raw.githubusercontent.com/Guilouz/Creality-K1-and-K1-Max/main/Scripts/installer.sh | bash
```
