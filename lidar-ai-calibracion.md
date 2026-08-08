# 🤖 Guía del LiDAR y Funciones IA de la K1 Max

El LiDAR de la K1 Max ofrece una resolución de **1μm**, lo que permite la **detección de primera capa** y la **calibración automática de flujo** (Motion Advance). Para su funcionamiento se requiere el firmware oficial de Creality (línea **V1.3.x**).

> ⚠️ **Importante:** No utilizar el mod de ballaswag (`creality_k1_klipper_mod`), ya que **elimina el LiDAR** de la configuración.

## ✅ Activación (pantalla táctil de la impresora)

1. Ve a **Ajustes** (icono de engranaje) → **Cámara** → **Función IA**.
2. Activa **First Layer Detection** (detección de primera capa): el LiDAR escanea la primera capa; si falta material o hay warping, la impresión se pausa y se muestra un aviso.
3. Activa **Motion Advance** (calibración de flujo): imprime un patrón zigzag en el lateral de la cama y lo escanea con el láser para ajustar el pressure advance (PA).
4. Usa la sensibilidad **media** (recomendada).
5. **IMPORTANTE:** de fábrica todas las calibraciones IA vienen **apagadas** — debes activarlas manualmente.

## 🖨️ Al iniciar la impresión

- Marca la casilla **Print Calibration** (en la pantalla de la K1 Max o al enviar el trabajo desde Creality Print).
- Si la casilla queda desmarcada, el LiDAR **NO se ejecuta**, aunque esté activado en los Ajustes.

## 🔄 Proceso visible de calibración

1. Calibración del láser.
2. Escaneo de la zona de calibración.
3. Impresión del patrón zigzag (lateral izquierdo de la cama — se puede retirar tras el escaneo).
4. Escaneo del patrón con el LiDAR.
5. Cálculo y aplicación del PA al archivo actual.

## 📋 Compatibilidad y limitaciones

| Aspecto | Detalle |
| --- | --- |
| Slicers compatibles | Gcode de Creality Print 4.3+, OrcaSlicer y PrusaSlicer |
| Calibración de flujo | PLA/ABS: sí — TPU/PA/fibra de carbono: no |
| Detección de primera capa | Sensibilidad baja no detecta warping sutil |
| Falsos positivos | Posibles con luz ambiental o colores especiales de filamento |
| Tiempo añadido | El LiDAR añade unos minutos al inicio de cada impresión calibrada |

## 🧭 Cuándo usar Print Calibration

**Obligatorio:**
- Al cambiar a un filamento distinto del anterior (ej. PLA → ABS).
- Al mover la máquina.
- Tras actualizar el firmware.

**No necesario:**
- Reimprimir el mismo modelo con éxito previo.
- Modelos pequeños centrados en la cama.

## 📚 Fuentes

- Wiki de Creality (AI Feature Description, Printing Parameter Settings).
- Foro de Creality.
