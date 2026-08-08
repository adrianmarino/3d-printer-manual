# ⚙️ Archivos de Configuración y Macros de la K1 Max

> **📌 Ver también:** [Configuración general](./k1-max-setup.md) — [Firmware y actualizaciones](./k1-max-firmware.md)

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
- **📄 Guía completa:** [Calentamiento rápido de cámara (HEATSOAK_CHAMBER)](./heatsoak-chamber.md)

### Otros Macros

- `xyz_ready` — Control de home para ejes
- `T0` — Definición de herramienta (nula para evitar errores)
- Macros de KAMP para malla adaptativa
- Macros de timelapse para grabación automática
