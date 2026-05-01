# 🛠️ Guía de Calibración del Z-Offset

El **Z-Offset** es la distancia exacta entre la boquilla (nozzle) y la cama de impresión. Un ajuste correcto es fundamental para que la primera capa se adhiera bien y la pieza no se despegue.


## 1️⃣ Preparación de la Impresora

Los materiales como el ABS expanden los componentes de la impresora al calentarse. **Nunca calibres con la impresora en frío.**

1. **Precalentamiento:** Sube la temperatura de la cama a **100°C** y la boquilla a **180°C** (lo suficiente para ablandar restos de plástico sin que gotee).
2. **Estabilización:** Espera de **10 a 15 minutos** con la cámara cerrada. Esto permite que el chasis de la impresora se dilate por completo y alcance su tamaño real de trabajo.
2. Posicion el cabezal en Home con el comando `G28`.


## 2️⃣ Calibración Inicial (Método del Papel)

Este paso se realiza desde la consola de comandos de Mainsail (la interfaz web de la impresora).

1. **Inicia la calibración:**
   Escribe el siguiente comando. La impresora buscará su punto de origen ("home") y se ubicará en el centro, bajando la sonda hasta tocar la cama.
   ```gcode
   PROBE_CALIBRATE
   ```

2. **Ajuste fino con papel:**
   Coloca un trozo de papel común entre la boquilla y la cama. Utiliza los controles de la interfaz de Mainsail ("Z-Position") o envía estos comandos por la consola para mover la boquilla:
   
   - Para **bajar** la boquilla (si el papel pasa sin resistencia):
     ```gcode
     TESTZ Z=-0.1    # Baja 0.1 mm
     TESTZ Z=-0.01   # Baja 0.01 mm (ajuste ultra fino)
     ```
   - Para **subir** la boquilla (si no puedes mover el papel):
     ```gcode
     TESTZ Z=0.1     # Sube 0.1 mm
     ```
   > 💡 **El punto ideal:** Mueve el papel mientras ajustas. Debes sentir que la boquilla roza y "atrapa" ligeramente el papel con una leve fricción, pero aún puedes moverlo.

3. **Guarda la configuración:**
   Cuando encuentres el punto perfecto, acepta y guarda los cambios con estos dos comandos:
   ```gcode
   ACCEPT
   SAVE_CONFIG
   ```


## 3️⃣ Prueba de Impresión y Ajustes "Al Vuelo"

Para comprobar que la calibración quedó perfecta, es ideal imprimir un cuadrado grande de una sola capa.

* **En tu laminador (OrcaSlicer / Creality Print):** 
  Crea un cubo de 280x280 mm y ajusta su altura (Z) a **0.2 mm** (exactamente una capa). Configura el patrón de relleno en **Monotónico** y reduce la velocidad de la primera capa a **30-40 mm/s**.

Mientras se imprime, observa la línea de plástico. Si notas defectos, ajusta la altura "al vuelo" desde la consola de Mainsail:

- 🔴 **Si la boquilla está MUY CERCA (capa casi transparente, rugosa u ondeada):**
  Aleja la boquilla subiendo el eje Z (usa un valor **positivo**).
  ```gcode
  SET_GCODE_OFFSET Z_ADJUST=0.02 MOVE=1
  ```

- 🔴 **Si la boquilla está MUY LEJOS (las líneas están separadas y no se pegan):**
  Acerca la boquilla bajando el eje Z (usa un valor **negativo**).
  ```gcode
  SET_GCODE_OFFSET Z_ADJUST=-0.02 MOVE=1
  ```
> 💡 **Tip:** Realiza ajustes muy pequeños (de 0.01 o 0.02) y espera a que la impresora aplique el cambio antes de volver a ajustar.

> ℹ️ **¿Se puede ajustar el Z-Offset sin estar imprimiendo?**
> Sí, puedes enviar el comando `SET_GCODE_OFFSET Z_ADJUST=... MOVE=1` desde la consola estando en reposo. Ten en cuenta lo siguiente:
> * **Requiere Home:** La impresora **debe** estar en Home (`G28`) para que funcione el parámetro `MOVE=1` (de lo contrario Klipper no sabe dónde está el cabezal).
> * **Sigue siendo temporal:** El cambio solo dura hasta que reinicies la impresora. Para hacerlo permanente debes guardarlo (ver siguiente sección).
> * **Uso ideal:** Es perfecto si acabas de terminar una impresión, notaste que la base quedó apenas muy aplastada o separada, y quieres aplicar la corrección inmediatamente para la próxima impresión sin tener que volver a hacer el método del papel.


### Guardar los Cambios Definitivos

Si tuviste que hacer "ajustes al vuelo" durante la impresión y lograste que la capa salga perfecta, **debes guardar esos cambios** para que el valor se transfiera al archivo de configuración (`printer.cfg`) y no se pierdan al apagar la impresora.

1. **Aplica el ajuste a la sonda:**
   Suma el ajuste temporal al valor base con este comando:
   ```gcode
   Z_OFFSET_APPLY_PROBE
   ```

2. **Guarda y reinicia:**
   Graba los cambios permanentemente y reinicia el sistema:
   ```gcode
   SAVE_CONFIG
   ```