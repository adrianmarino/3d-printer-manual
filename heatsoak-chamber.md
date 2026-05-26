# 🔥 Macro HEATSOAK_CHAMBER

Esta macro acelera el calentamiento de la cámara usando convección forzada con turbinas 5015. Está pensada para impresoras como la Creality K1 Max, donde el calor de la cámara y la recirculación de aire mejoran la impresión de materiales exigentes como ABS.

## ¿Qué hace esta macro?

- Hace `G28` para asegurar un home seguro de todos los ejes.
- Posiciona el cabezal en el centro de la cama y baja la cama a `Z50` para evitar colisiones.
- Inicia el calentamiento de la cama a la temperatura definida.
- Fuerza el ventilador de la cámara y el pin del ventilador al máximo para crear convección.
- Realiza un ciclo lento entre `Z50` y `Z150` para mezclar el aire caliente dentro de la cámara.
- Al final, reduce el objetivo del ventilador de cámara al valor de trabajo deseado.

## Macro completa

```ini
# ====================================================================
# VARIABLES GLOBALES DE CONTROL PARA EL PRECALENTAMIENTO
# ====================================================================
[gcode_macro _HEATSOAK_VARS]
variable_start_time: 0
variable_bed_temp: 100
variable_chamber_target: 50
gcode:

# ====================================================================
# MACRO PRINCIPAL: HEATSOAK_CHAMBER
# ====================================================================
[gcode_macro HEATSOAK_CHAMBER]
description: Calentamiento inteligente de cámara para ABS (Movimiento lento y convección)
gcode:
    {% set BED_TEMP = params.BED_TEMP|default(100)|float %}
    {% set CHAMBER_TARGET = params.CHAMBER_TARGET|default(50)|float %}
    {% set CURRENT_CHAMBER = printer["temperature_fan chamber_fan"].temperature|float %}

    # CASO 1: Si la cámara ya está caliente, omitimos el proceso
    {% if CURRENT_CHAMBER >= CHAMBER_TARGET %}
        {action_respond_info("La cámara ya está a %s°C (Objetivo: %s°C). Omitiendo calentamiento." % (CURRENT_CHAMBER|round(1), CHAMBER_TARGET))}
        SET_TEMPERATURE_FAN_TARGET TEMPERATURE_FAN=chamber_fan TARGET={CHAMBER_TARGET}
    
    # CASO 2: Si falta calor, inicializamos la rutina de convección lenta
    {% else %}
        {action_respond_info("Cámara a %s°C. Iniciando convección forzada ultra lenta hasta alcanzar %s°C..." % (CURRENT_CHAMBER|round(1), CHAMBER_TARGET))}
        
        # Guardar parámetros en la memoria de variables globales
        SET_GCODE_VARIABLE MACRO=_HEATSOAK_VARS VARIABLE=start_time VALUE={printer.toolhead.estimated_print_time}
        SET_GCODE_VARIABLE MACRO=_HEATSOAK_VARS VARIABLE=bed_temp VALUE={BED_TEMP}
        SET_GCODE_VARIABLE MACRO=_HEATSOAK_VARS VARIABLE=chamber_target VALUE={CHAMBER_TARGET}
        
        # Preparación física de seguridad
        G28 ; Home de todos los ejes
        G90 ; Posicionamiento absoluto
        G1 X150 Y150 Z50 F3000 ; Cabezal al centro para no estorbar
        
        # Encendido de calentador y turbinas 5015
        M140 S{BED_TEMP} ; Calentar cama
        SET_TEMPERATURE_FAN_TARGET TEMPERATURE_FAN=chamber_fan TARGET=70 ; Evita que Klipper bloquee el pin
        SET_PIN PIN=fan1 VALUE=255 ; Encender tus dos turbinas 5015 al 100%
        
        # Disparar el temporizador para la primera evaluación en 1 segundo
        UPDATE_DELAYED_GCODE ID=HEATSOAK_CHAMBER_TICK DURATION=1
    {% endif %}

# ====================================================================
# TEMPORIZADOR DE CONTROL: HEATSOAK_CHAMBER_TICK
# ====================================================================
[delayed_gcode HEATSOAK_CHAMBER_TICK]
gcode:
    # Recuperar las variables guardadas en el macro principal
    {% set BED_TEMP = printer["gcode_macro _HEATSOAK_VARS"].bed_temp|float %}
    {% set CHAMBER_TARGET = printer["gcode_macro _HEATSOAK_VARS"].chamber_target|float %}
    {% set CURRENT_CHAMBER = printer["temperature_fan chamber_fan"].temperature|float %}

    # CONDICIÓN DE PARADA: ¿Llegamos al objetivo de temperatura?
    {% if CURRENT_CHAMBER >= CHAMBER_TARGET %}
        
        # Calcular el tiempo neto demorado en el proceso
        {% set startTime = printer["gcode_macro _HEATSOAK_VARS"].start_time %}
        {% set endTime = printer.toolhead.estimated_print_time %}
        {% set totalSeconds = (endTime - startTime)|int %}
        {% set minutes = (totalSeconds / 60)|int %}
        {% set seconds = (totalSeconds % 60)|int %}

        M117 ¡Cámara Lista!
        {action_respond_info("Temperatura alcanzada: %s°C. Tiempo demorado: %s min %s seg" % (CURRENT_CHAMBER|round(1), minutes, seconds))}
        
        # Apagar este bucle temporizado
        UPDATE_DELAYED_GCODE ID=HEATSOAK_CHAMBER_TICK DURATION=0
        # Devolver el extractor trasero al comportamiento térmico normal de impresión
        SET_TEMPERATURE_FAN_TARGET TEMPERATURE_FAN=chamber_fan TARGET={CHAMBER_TARGET}

    # CONDICIÓN DE CONTINUIDAD: Si falta calor, movemos la cama muy lento
    {% else %}
        # Ciclo de fuelle térmico continuo a 5 mm/s (F300). 
        # Tarda exactamente 20 segundos en bajar y 20 segundos en subir.
        G1 Z150 F300   ; Baja la cama alejándola de la boquilla
        G1 Z50 F300    ; Sube la cama acercándola a la boquilla
        
        # Programar la siguiente verificación justo cuando termine el movimiento de arriba (40 segundos en total)
        UPDATE_DELAYED_GCODE ID=HEATSOAK_CHAMBER_TICK DURATION=1
    {% endif %}
```

## Parámetros

- `BED_TEMP`: Temperatura objetivo de la cama. Por defecto `100`.
- `CHAMBER_TARGET`: Temperatura objetivo de la cámara después del precalentamiento rápido. Por defecto `50`.

Puedes invocar la macro así:

```gcode
HEATSOAK_CHAMBER BED_TEMP=100 CHAMBER_TARGET=55
```

## ¿Por qué es mejor para ABS?

### 1. El ABS sufre por gradientes térmicos

El ABS no solo necesita una cama caliente, sino también una cámara estable. Las diferencias de temperatura entre la base y la parte superior de la pieza provocan warping y delaminación.

### 2. Elimina puntos fríos

La convección forzada y el movimiento lento de la cama rompen las bolsas de aire frío que quedan en las esquinas inferiores de la K1 Max. Esto ayuda a distribuir el calor de forma más homogénea dentro de la cámara.

### 3. Mantiene presión térmica positiva

En lugar de extraer aire caliente, este método recircula y mezcla el aire con los ventiladores 5015. Eso conserva el calor dentro de la cámara, lo que es vital para que las capas de ABS se fusionen bien.

## Recomendaciones

- Usa esta macro antes de iniciar una impresión con ABS o materiales sensibles al enfriamiento.
- Ajusta `BED_TEMP` y `CHAMBER_TARGET` según tu perfil de material.
- Verifica que los ventiladores y sensores de la cámara estén correctamente configurados en tu `printer.cfg`.

> Nota: Esta macro está diseñada para impresoras con cámara cerrada y ventiladores de recirculación. Asegúrate de que tu hardware soporte el flujo de aire y la temperatura objetivo.
