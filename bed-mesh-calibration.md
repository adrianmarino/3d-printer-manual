# 🗺️ Calibración de la Cama (Bed Mesh)

La malla de nivelación de la cama (Bed Mesh) en Klipper crea un mapa topográfico de la superficie de impresión y corrige las variaciones de altura en tiempo real. Durante la impresión, Klipper ajusta la posición del eje Z en cada punto de la cama para mantener una separación constante entre la boquilla y el lecho, lo que mejora mucho la calidad de la primera capa.

Si usas la calibración adaptativa nativa de Klipper (o KAMP), lo ideal es contar con una **Malla Base** o **Ancla de Seguridad**. Esta malla completa debe generarse con la cama a la temperatura de trabajo y guardarse como referencia estable.

Es recomendable crear una sola malla completa para cada temperatura o material habitual (por ejemplo, una matriz de 9x9 o 11x11). Hazla con la cama caliente y deja que el sistema se estabilice unos 10-15 minutos antes de calibrar. Luego guarda esa malla en la configuración como `default` o con un nombre claro.

**¿Por qué hacerlo así?**

Klipper usa la malla completa como un **mapa topográfico de referencia**. Si la calibración adaptativa genera pocos puntos por una pieza pequeña, Klipper combina esa micro-malla con la tendencia general de la malla base para evitar puntos erráticos y prevenir colisiones del nozzle.

---

## 1️⃣ Preparación Térmica (Muy Importante)

Al igual que con el Z-Offset, la cama sufre una expansión térmica y se deforma al calentarse (especialmente a altas temperaturas como 100°C para ABS). **Siempre debes generar la malla con la cama caliente.**

1. **Precalentamiento:** Calienta la cama a la temperatura de trabajo que usarás para imprimir (ej. **100°C** para ABS).
2. **Estabilización:** Espera de **10 a 15 minutos** para que toda la cama alcance la temperatura de manera uniforme y se expanda por completo.
3. **Home:** Haz un Home de todos los ejes enviando el comando `G28`.

---

## 2️⃣ Generación de la Malla

Para comenzar el sondeo de la cama, ve a la consola de comandos de Mainsail y envía el comando de calibración:

```gcode
BED_MESH_CALIBRATE
```

La impresora comenzará a medir múltiples puntos a lo largo de toda la superficie de la cama para crear un mapa topográfico en 3D. Espera a que termine por completo.

---

## 3️⃣ Guardar el Perfil de la Malla

Una vez que la impresora termine de sondear todos los puntos, **debes guardar esa calibración**.

En Klipper, es una excelente práctica guardar las mallas con un nombre específico (crear un perfil). Esto te permite tener distintas mallas para diferentes materiales o temperaturas, ya que la cama no se deforma igual a 60°C que a 100°C.

Para guardar la malla que acabas de generar con el nombre `cr_abs`, envía este comando:

```gcode
BED_MESH_PROFILE SAVE=cr_abs
```

> 💡 **Tip:** Puedes usar el nombre que quieras en lugar de `cr_abs`. Por ejemplo: `pla_60`, `petg_80`, etc., para saber exactamente de qué perfil se trata.

---

## 4️⃣ Guardar los Cambios Definitivos

Al igual que ocurre con cualquier cambio importante en Klipper, para que este nuevo perfil no se borre al reiniciar la máquina, debes guardarlo permanentemente en el archivo de configuración maestro (`printer.cfg`). Envía:

```gcode
SAVE_CONFIG
```
La impresora se reiniciará automáticamente.

---

## 📌 ¿Cómo usar este perfil al imprimir?

Para que Klipper utilice esta malla compensatoria mientras imprimes tu pieza, tienes dos opciones:

1. **Carga Manual:** Antes de lanzar una impresión, envía este comando por la consola para activar la malla:
   ```gcode
   BED_MESH_PROFILE LOAD=cr_abs
   ```

2. **Automático (Recomendado):** Agrega el comando `BED_MESH_PROFILE LOAD=cr_abs` dentro de tu macro de `START_PRINT` (o en el G-code de inicio de tu laminador) para que la impresora cargue la malla correcta de forma automática en cada impresión.
