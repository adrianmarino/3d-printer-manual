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

La medición no es un test directo de la tensión de una correa ni de la calidad de una pieza. Klipper excita el movimiento de la impresora a distintas frecuencias y el acelerómetro registra cómo responde el sistema completo: motores, correas, poleas, guías, gantry, cabezal, bastidor, cableado y cualquier pieza que transmita esa vibración.

### 6.1 Leer los ejes y las curvas

- **Eje horizontal (Hz):** frecuencia de excitación. Por ejemplo, 45 Hz significa 45 oscilaciones por segundo.
- **Eje vertical (PSD):** intensidad de la respuesta medida. Los picos indican frecuencias donde la estructura responde con mayor energía.
- **Gráfica `resonances_x`:** Klipper ordena movimiento en X. **No significa** que solo vibre el eje físico X del acelerómetro.
- **Gráfica `resonances_y`:** Klipper ordena movimiento en Y.
- **Curvas `X`, `Y` y `Z`:** componentes físicas que detecta el acelerómetro. Una excitación en X puede transmitirse a Y y Z por flexión, torsión o vibración vertical.
- **`X+Y+Z`:** energía combinada de las tres componentes; es útil para localizar los picos relevantes del sistema.
- **`After shaper`:** estimación de la respuesta después de aplicar el shaper elegido. No es una segunda medición física: muestra qué picos debería atenuar el filtro.

Un pico alto dice: «a esta frecuencia la máquina vibra con facilidad». No identifica por sí solo la pieza que vibra ni demuestra que esa vibración deje ghosting en la pieza.

### 6.2 Encontrar resonancias relevantes

Leer cada gráfica en este orden:

1. **Ubicar el pico dominante.** Es la frecuencia más evidente de respuesta del conjunto medido.
2. **Buscar picos secundarios o bandas anchas.** Dos picos separados suelen indicar modos mecánicos distintos; una banda ancha es más difícil de compensar que un pico estrecho.
3. **Comparar las componentes del acelerómetro dentro de la misma gráfica.** Un pico visible también en Z puede indicar flexión o transmisión vertical; uno concentrado en otra componente puede sugerir torsión o movimiento transversal.
4. **Mirar `After shaper`.** En la zona problemática debe bajar claramente respecto de la respuesta original. Si queda mucha energía a baja frecuencia, el filtro quizá no pueda reducirla sin demasiado coste.
5. **Revisar el resultado numérico de Klipper.** Es la decisión que se guarda; la imagen sirve para comprenderla y comparar mediciones.

No comparar directamente la altura absoluta de un pico de `resonances_x` con uno de `resonances_y` si las escalas de PSD son distintas. Tampoco comparar cuantitativamente archivos generados con procedimientos u orígenes de datos diferentes. Comparar primero la forma del espectro y repetir siempre en condiciones equivalentes.

En una CoreXY, X e Y se producen con las dos correas. Resonancias parecidas entre ambas direcciones pueden ser esperables; una diferencia no permite asignar un pico a la correa A o B. Las gráficas de Klipper describen la dinámica completa, no la frecuencia propia de una correa aislada. Por eso no usar los Hz de estas gráficas para calcular tensión en newtons.

### 6.3 Elegir entre los shapers que propone Klipper

Las curvas punteadas de `ZV`, `MZV`, `EI`, `2HUMP_EI` y `3HUMP_EI` son filtros candidatos, no vibraciones medidas. Klipper evalúa cada uno y muestra:

- **`vibrations`:** vibración residual estimada después del filtro. Menor es mejor.
- **`smoothing`:** suavizado que el filtro introduce en la trayectoria. Menor preserva mejor esquinas, detalle y aceleración práctica.
- **`suggested max_accel`:** límite de aceleración sugerido para evitar suavizado excesivo con ese shaper.

El valor menor de `vibrations` no gana automáticamente. Un filtro más agresivo puede reducir el ringing pero exigir mucho `smoothing` y una aceleración baja. Por ejemplo, un `3HUMP_EI` puede dejar menos vibración residual que `ZV`, pero si reduce `suggested max_accel` de forma marcada, puede redondear piezas y ralentizar impresiones más de lo que conviene.

Un pico único, estrecho y bien definido suele ser un buen caso para Input Shaper. Una respuesta repartida entre frecuencias bajas, varios picos o una banda ancha puede requerir un filtro agresivo para mejorar poco. En ese caso, revisar primero la mecánica en lugar de subir el suavizado o reducir la aceleración a ciegas.

### 6.4 Vibración medida, resonancia y ghosting no son sinónimos

El acelerómetro mide vibración, no el desplazamiento real de la boquilla respecto de la pieza. Una tapa, un riser o un panel pueden producir un pico grande y, aun así, afectar poco la superficie si no cambian de forma significativa la posición de la boquilla.

La prueba final es una impresión de ringing/ghosting con las mismas velocidades, aceleraciones y geometría. Comparar la misma pieza antes y después de un cambio mecánico:

- **Ecos más débiles o menos visibles** alrededor de esquinas: mejora real de impresión.
- **La gráfica cambia pero la pieza no:** probablemente se redujo una vibración parásita que el acelerómetro detecta pero no domina la posición de la boquilla.
- **La pieza empeora aunque la gráfica parezca mejor:** revisar el shaper, `max_accel`, velocidad, flujo y condiciones de la prueba; no decidir solo por una imagen.

Input Shaper reduce ringing, pero no corrige piezas flojas, correas dañadas, poleas que patinan, guías con juego ni desplazamientos de capa.

## 7. Diagnosticar un pico bajo o una respuesta anómala

Una resonancia estable alrededor de 40–50 Hz puede aparecer en una K1 Max sin señalar por sí sola una avería. Un modo fuerte y repetible a frecuencias bajas, aproximadamente 10–25 Hz, merece aislarse antes de compensarlo con un shaper. Puede corresponder a una masa o estructura grande: tapa, riser, paneles, PTFE, cableado, gantry, bastidor o soporte de la impresora.

No modificar tensión de correas al azar a partir de una sola gráfica. Ejecutar mediciones controladas y cambiar **una variable cada vez**:

1. **Establecer una referencia.** Misma posición inicial, misma temperatura aproximada, mismo acelerómetro, misma macro y ninguna pieza en la cama.
2. **Aislar riser y tapa.** Medir sin riser ni tapa, con riser sin tapa y con riser más tapa. Si el pico aparece solo al añadir una pieza, revisar sus holguras, apoyos y fijaciones.
3. **Revisar PTFE y cableado.** Repetir la medición con el tubo y los cables guiados en un arco amplio, sin tocar tapa o riser, sin tensar el cabezal y sin poner manos dentro de la zona de movimiento. Si el espectro cambia, corregir la ruta o el alivio de tensión.
4. **Descartar el soporte.** Si es seguro mover la impresora, comparar con una superficie rígida. Un modo que no cambia de forma apreciable al cambiar mesa por suelo es menos probable que provenga del mueble.
5. **Inspeccionar la mecánica interna.** Con la impresora apagada, revisar tensión y equilibrado de correas, fijación de poleas, idlers, tornillos del gantry, juego de carros y guías, montaje del hotend y del acelerómetro. Corregir solo una causa plausible y volver a medir.
6. **Validar en una impresión.** Repetir el mismo test de ringing y comparar la superficie. La pieza, no solo el PSD, decide si el cambio vale la pena.

Registrar cada prueba: fecha, configuración de tapa/riser, ruta de PTFE, superficie de apoyo, valores de shaper, `smoothing`, `suggested max_accel` y resultado de impresión. Las diferencias pequeñas entre mediciones pueden ser repetibilidad; un cambio de forma o frecuencia que aparece sistemáticamente al cambiar una sola variable es evidencia más útil.

## 8. Referencias

1. <a href="https://www.klipper3d.org/Measuring_Resonances.html" target="_blank" rel="noopener noreferrer">Klipper — Measuring Resonances</a>. Calibración automática, gráficos y compromiso entre vibración residual y suavizado.
2. <a href="https://www.klipper3d.org/Resonance_Compensation.html" target="_blank" rel="noopener noreferrer">Klipper — Resonance Compensation</a>. Selección de `max_accel` y efecto del suavizado.
3. <a href="https://docs.mainsail.xyz/features/custom-themes/custom-navigation" target="_blank" rel="noopener noreferrer">Mainsail — Custom Navigation</a>. Entradas de navegación mediante `.theme/navi.json`.

---

[← Volver al índice](./README.md)
