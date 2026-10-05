# 🫨 Calibración de Input Shaper y gráficas de resonancia X/Y

Esta guía instala una macro para la **Creality K1 Max** que mide las resonancias de los ejes X e Y, calcula y guarda los parámetros de Klipper Input Shaper y genera las gráficas PNG correspondientes. Está orientada a una K1 Max con Klipper, Moonraker, Mainsail e Improved Shapers ya instalados.

> **Seguridad:** ejecutar la calibración con la impresora libre, sin impresión activa, sin piezas sueltas en la cama y con el recorrido del cabezal despejado. La macro mueve el cabezal y reinicia Klipper al final.

## 1. Qué hace la macro

`INPUT_SHAPER_CALIBRATION` ejecuta un único barrido de frecuencias para ambos ejes. Durante esa ejecución:

1. Hace *home* si X, Y y Z no están referenciados.
2. Ejecuta `SHAPER_CALIBRATE NAME=calibration` para X e Y.
3. Calcula el tipo de shaper y su frecuencia para cada eje.
4. Genera `resonances_x.png` y `resonances_y.png` a partir de los CSV temporales de esa misma medición.
5. Guarda los valores en `printer.cfg` mediante `SAVE_CONFIG` y reinicia Klipper.

No es necesario ejecutar un segundo test para obtener las gráficas. Los CSV se eliminan al terminar; las PNG permanecen disponibles.

## 2. Requisitos

- Klipper funcional con acelerómetro y las secciones `[resonance_tester]` e `[input_shaper]` configuradas.
- Improved Shapers instalado en `/usr/data/printer_data/config/Helper-Script/improved-shapers/`.
- El archivo de configuración de Improved Shapers incluido desde `printer.cfg`.
- Mainsail disponible en `http://<IP_DE_LA_IMPRESORA>:4409`.

Para la K1 Max de esta guía, mantener `max_freq: 100` en `[resonance_tester]`. Ese límite evita superar la cola de movimientos del MCU durante el barrido. No cambiar `accel_per_hz` sin una razón medida.

## 3. Dar de alta la macro

Abrir por SSH el archivo:

```text
/usr/data/printer_data/config/Helper-Script/improved-shapers/improved-shapers.cfg
```

El archivo debe incluir estas definiciones de comandos de shell. `resonance_graph` convierte los CSV en PNG; los otros comandos eliminan resultados anteriores y temporales.

```ini
[gcode_shell_command resonance_graph]
command: /usr/data/printer_data/config/Helper-Script/improved-shapers/scripts/calibrate_shaper.py
timeout: 600.0
verbose: False

[gcode_shell_command delete_graph]
command: sh /usr/data/helper-script/files/improved-shapers/delete_graph.sh
timeout: 600.0
verbose: False

[gcode_shell_command delete_csv]
command: sh /usr/data/helper-script/files/improved-shapers/delete_csv.sh
timeout: 600.0
verbose: False
```

Agregar o reemplazar la macro con el siguiente bloque:

```ini
[gcode_macro INPUT_SHAPER_CALIBRATION]
description: Measure, apply Input Shaper, and generate X/Y graphs
gcode:
  {% set x_png = params.X_PNG|default("/usr/data/printer_data/config/Helper-Script/improved-shapers/resonances_x.png") %}
  {% set y_png = params.Y_PNG|default("/usr/data/printer_data/config/Helper-Script/improved-shapers/resonances_y.png") %}
  RUN_SHELL_COMMAND CMD=delete_graph
  {% if printer["configfile"].config["temperature_fan soc_fan"] %}
    SET_TEMPERATURE_FAN_TARGET TEMPERATURE_FAN=soc_fan TARGET=30
  {% endif %}
  {% if printer.toolhead.homed_axes != "xyz" %}
    RESPOND TYPE=command MSG="Homing..."
    G28
  {% endif %}
  RESPOND TYPE=command MSG="Measuring X and Y Resonances..."
  SHAPER_CALIBRATE NAME=calibration
  M400
  RESPOND TYPE=command MSG="Generating X Graph... This may take some time."
  RUN_SHELL_COMMAND CMD=resonance_graph PARAMS="/tmp/calibration_data_x_calibration.csv -o {x_png}"
  RESPOND TYPE=command MSG="Generating Y Graph... This may take some time."
  RUN_SHELL_COMMAND CMD=resonance_graph PARAMS="/tmp/calibration_data_y_calibration.csv -o {y_png}"
  {% if printer["configfile"].config["temperature_fan soc_fan"] %}
    SET_TEMPERATURE_FAN_TARGET TEMPERATURE_FAN=soc_fan TARGET=45
  {% endif %}
  RUN_SHELL_COMMAND CMD=delete_csv
  RESPOND TYPE=command MSG="Input Shaper calibration and graphs complete!"
  SAVE_CONFIG
```

Reiniciar Klipper desde Mainsail. La macro debe aparecer en **Macros** con el nombre `INPUT_SHAPER_CALIBRATION`.

## 4. Ejecutar la calibración

1. Quitar la pieza impresa, limpiar la cama y confirmar que el cabezal puede moverse sin obstáculos.
2. Esperar a que no haya una impresión ni una macro en curso.
3. En Mainsail, abrir **Macros** y pulsar `INPUT_SHAPER_CALIBRATION`.
4. Esperar el mensaje `Input Shaper calibration and graphs complete!` y el reinicio de Klipper.
5. Confirmar que Mainsail vuelve al estado `ready`.

No usar para este procedimiento la opción de Input Shaping de la pantalla Creality: ese flujo no está vinculado a esta macro ni garantiza que actualice las PNG.

Los valores aplicados quedan en el bloque autoguardado de `/usr/data/printer_data/config/printer.cfg`:

```ini
#*# [input_shaper]
#*# shaper_type_x = ei
#*# shaper_freq_x = 39.8
#*# shaper_type_y = ei
#*# shaper_freq_y = 53.4
```

Los números son solo un ejemplo. Usar siempre los que haya escrito la última calibración de la propia impresora.

## 5. Consultar las gráficas en Mainsail

Las gráficas se guardan aquí:

```text
/usr/data/printer_data/config/Helper-Script/improved-shapers/resonances_x.png
/usr/data/printer_data/config/Helper-Script/improved-shapers/resonances_y.png
```

Se pueden abrir directamente desde el navegador:

```text
http://<IP_DE_LA_IMPRESORA>:4409/server/files/config/Helper-Script/improved-shapers/resonances_x.png
http://<IP_DE_LA_IMPRESORA>:4409/server/files/config/Helper-Script/improved-shapers/resonances_y.png
```

Para dejarlas disponibles desde la barra lateral de Mainsail, crear o editar `/usr/data/printer_data/config/.theme/navi.json` y agregar estas entradas al arreglo JSON existente:

```json
{
  "title": "Resonancia X",
  "href": "/server/files/config/Helper-Script/improved-shapers/resonances_x.png",
  "target": "_blank",
  "position": 80
},
{
  "title": "Resonancia Y",
  "href": "/server/files/config/Helper-Script/improved-shapers/resonances_y.png",
  "target": "_blank",
  "position": 81
}
```

Mainsail carga estas opciones desde `.theme/navi.json`. Recargar la página con `Ctrl+F5` después de editarlo. Si una gráfica parece antigua tras una nueva calibración, abrir el enlace en una pestaña nueva o forzar la recarga: la URL no cambia y el navegador puede mostrar una imagen en caché.

## 6. Interpretar las gráficas

Cada gráfica representa la respuesta medida mientras Klipper excita un eje:

- **Eje horizontal (Hz):** frecuencia de la vibración aplicada.
- **Eje vertical:** intensidad de la respuesta medida por el acelerómetro; valores mayores indican resonancias más fuertes.
- **Picos:** frecuencias a las que la estructura responde más. No elegir manualmente el pico más alto como frecuencia de shaper: `SHAPER_CALIBRATE` evalúa toda la respuesta y el compromiso entre vibración residual y suavizado.

La gráfica **X** mide el movimiento comandado en X y la gráfica **Y** el movimiento comandado en Y. En una CoreXY ambas correas, poleas y el bastidor participan en ambos movimientos; un pico no identifica por sí solo una correa concreta.

El resultado de Klipper muestra, para cada shaper candidato:

- **`vibrations`:** vibración residual estimada. Menor es mejor.
- **`smoothing`:** suavizado introducido en la trayectoria. Menor conserva mejor esquinas y detalle.
- **`suggested max_accel`:** aceleración máxima recomendada para no introducir suavizado excesivo con ese shaper.

Un shaper más agresivo, como `ei`, `2hump_ei` o `3hump_ei`, puede reducir más ringing, pero normalmente añade más suavizado y reduce la aceleración práctica. No subir `max_accel` por encima de la recomendación solo para conservar velocidad.

### Qué buscar al comparar mediciones

- **Picos más bajos o más estrechos después de un ajuste mecánico:** normalmente indican menor respuesta resonante.
- **Picos nuevos, más altos o desplazados:** revisar tensión y equilibrado de correas, fijación de poleas, tornillos, guías, holguras del cabezal y elementos sueltos antes de compensarlos con software.
- **Variaciones pequeñas entre dos gráficas:** pueden deberse a temperatura, posición del cabezal, tensión de correas o repetibilidad de la medición. Comparar siempre con la misma configuración mecánica y condiciones similares.
- **Resultado con `suggested max_accel` bajo:** priorizar ese límite o revisar la mecánica; elegir un shaper más agresivo no repara una holgura.

Input Shaper reduce el *ringing*, pero no corrige piezas flojas, correas dañadas, poleas que patinan ni desplazamientos de capa. Después de cualquier corrección mecánica, repetir la calibración y hacer una impresión de prueba con esquinas y círculos.

## 7. Referencias

1. <a href="https://www.klipper3d.org/Measuring_Resonances.html" target="_blank" rel="noopener noreferrer">Klipper — Measuring Resonances</a>. Calibración automática, gráficos y compromiso entre vibración residual y suavizado.
2. <a href="https://www.klipper3d.org/Resonance_Compensation.html" target="_blank" rel="noopener noreferrer">Klipper — Resonance Compensation</a>. Selección de `max_accel` y efecto del suavizado.
3. <a href="https://docs.mainsail.xyz/features/custom-themes/custom-navigation" target="_blank" rel="noopener noreferrer">Mainsail — Custom Navigation</a>. Entradas de navegación mediante `.theme/navi.json`.

---

[← Volver al índice](./README.md)
