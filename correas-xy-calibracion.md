# 📏 Calibración de las Correas XY de la K1 Max con BIQU Belter

Esta guía explica cómo preparar el **BIQU Belter**, comprobar su estimación de tensión en **newtons (N)** y comparar y ajustar las dos correas del sistema CoreXY de la **Creality K1 Max**.

**Referencia práctica de trabajo: 6,0 N por correa, dentro de 5,5–6,5 N, con ambas equilibradas.** Se adopta como objetivo **provisional**: coincide con el rango publicado por Creality y con un testimonio de un usuario que afirma usar el Belter siguiendo una indicación de soporte. No se encontró una especificación oficial que vincule inequívocamente ese rango con la medición individual mediante Belter. [1][3]

> **Alcance:** correas XY y mecanismo de tensión original. No aplicar este objetivo a la correa Z ni asumir que sirve para una máquina con correas, poleas o tensores modificados.

## 1. Qué está confirmado y qué sigue siendo incierto

Investigación consultada el **2 de octubre de 2026**.

| Fuente | Información encontrada | Cómo interpretarla |
| --- | --- | --- |
| Wiki oficial de Creality para la serie K1 | Rango de 5,5–6,5 N y exigencia de tensión consistente entre ambas correas; incluye la condición de que las dos correas estén juntas. | Es el rango oficial publicado, pero la guía no define suficientemente el instrumento ni la geometría de esa comprobación. [1] |
| Comentario de usuario en una publicación sobre K1 Max | Afirma que soporte indicó 6,0 ± 0,5 N y que usa el BIQU Belter para comprobar sus correas. | Es el indicio específico para adoptar 6 N por correa con Belter como referencia provisional. Se pudo consultar el texto indexado, no la publicación completa ni la respuesta original de soporte. [3] |
| Usuario de K1 con Belter en Reddit | Pregunta qué valor usar y se discuten discrepancias de la antigua tabla de conversión; otro participante comprueba la herramienta con pesos conocidos. | Confirma que otros usuarios tuvieron el mismo problema. No establece una especificación oficial ni valida universalmente la tabla antigua. [4] |
| Usuario de K1C con Belter en el foro de Creality | Reporta unos 19 N después de ajustar con el procedimiento de los resortes. | Es una experiencia de otra variante de la serie K1; no demuestra la tensión real ni establece un objetivo para la K1 Max. [5] |
| Wiki y calculadora actuales de BIQU | Publican calibración del cero, un modelo no lineal y calibración opcional mediante cargas conocidas. | Proporcionan el procedimiento para estimar y comparar tensión con el Belter. [2] |

No se encontró un procedimiento confirmado que interprete los 5,5–6,5 N como la fuerza transversal necesaria para juntar dos tramos. Esa interpretación es una posibilidad, no una instrucción del fabricante demostrada por la investigación.

## 2. No confundir mm, N y Hz

- **mm en la pantalla del Belter:** lectura de desplazamiento. No es directamente la tensión y depende del cero y de la configuración de la herramienta.
- **N en la calculadora:** estimación de la tensión de la correa obtenida a partir de la lectura y la calibración.
- **Hz al pulsar la correa:** frecuencia de vibración de un tramo libre. Para convertirla a N se necesita su longitud y su masa por unidad de longitud.

En la comunidad se utiliza aproximadamente **110 Hz sobre un tramo libre de 150 mm** como referencia de ajuste, también para K1 Max. No es una equivalencia verificada con 6 N en las correas originales. [6]

Por ejemplo, Voron relaciona 110 Hz sobre 150 mm con aproximadamente 2 lbf, es decir, **8,9 N para su configuración**. No trasladar esa equivalencia automáticamente a la K1 Max. [7]

Tampoco reutilizar valores en mm de otros tensiómetros ni de un Belter con otro cero. Esta guía no establece una lectura universal de pantalla.

## 3. Herramientas y archivos imprimibles

- BIQU Belter con batería y estructura firme.
- Calibre para medir el espesor de la correa.
- Llave Allen de 2 mm para los tornillos correspondientes del mecanismo original, según la revisión de la impresora. [1]
- Calculadora: **[belter.bttwiki.com](https://belter.bttwiki.com/)**.
- Para comprobar la conversión: tramo de correa aparte, preferentemente del mismo tipo y espesor, soporte fijo, recipiente y balanza.

| Pieza | Uso | Archivo oficial |
| --- | --- | --- |
| ProbeTip | Punta de contacto necesaria para la configuración documentada. | [ProbeTip.STEP](https://github.com/bigtreetech/Belter-belt-tension-Tool/blob/master/PrintParts/ProbeTip.STEP) |
| Hand Held bracket | Soporte para uso con una mano. | [Hand Held bracket.STEP](https://github.com/bigtreetech/Belter-belt-tension-Tool/blob/master/PrintParts/Hand%20Held%20bracket.STEP) |
| Plunger | Accionamiento para uso con una mano. | [Plunger.STEP](https://github.com/bigtreetech/Belter-belt-tension-Tool/blob/master/PrintParts/Plunger.STEP) |
| Zeroing tool | Referencia para calibrar la herramienta. | [BIQU Belter Zeroing tool.STL](https://github.com/bigtreetech/Belter-belt-tension-Tool/blob/master/Calculation%20Tool/BIQU%20Belter%20Zeroing%20tool.STL) |

**La pieza de calibración está en `Calculation Tool`, no en `PrintParts`.** La wiki dirige a `PrintParts` para las piezas, pero el STL del cero se encuentra en la otra carpeta del repositorio. [2][8]

## 4. Calibrar el cero del Belter

Seguir las imágenes de la sección **Calibration Process** de la [wiki de BIQU](https://global.bttwiki.com/belter.html#calibration-process). [2]

1. Instalar la punta y los accesorios de la configuración documentada.
2. Asentar el conjunto del soporte contra el medidor de profundidad y comprobar que los tornillos estén firmes y que no haya juego.
3. **Poner la lectura del medidor en cero**, siguiendo la posición mostrada por BIQU.
4. **Instalar después la pieza `Zeroing tool`.**
5. Anotar la lectura y escribirla en **Belter Calibration Reading** de la calculadora.
6. Medir con el calibre el espesor de la correa como muestra la wiki, sin aplastarla, e introducirlo en **Belt Thickness**.
7. Mantener la misma configuración de punta, cero y accesorios para todas las mediciones.

No poner nuevamente el medidor en cero después de instalar la pieza de calibración: su lectura es el dato que necesita la calculadora.

El cero geométrico y la calibración del modelo de conversión son pasos distintos. El primero es necesario; el segundo permite comprobar y mejorar la estimación en N.

## 5. Comprobar la conversión con pesos conocidos

Antes de ajustar una máquina únicamente por un valor absoluto de 6 N, conviene comprobar que el Belter estima correctamente fuerzas cercanas a ese objetivo. BIQU documenta una calibración con una correa y cargas suspendidas. [2]

### Montaje de comprobación

1. Utilizar un **tramo de correa aparte**, fuera de la impresora. No colgar pesos del cabezal ni de las correas instaladas.
2. Sujetar arriba un extremo y dejar suspendido del extremo inferior un recipiente con una masa total conocida.
3. Medir la masa total: **recipiente, agua y elementos de sujeción que cuelguen del extremo inferior**.
4. Esperar a que la carga quede quieta y medir en el tramo libre, lejos de las sujeciones.
5. Sostener el Belter durante la medición para que su peso no añada carga longitudinal al tramo.

La tensión ideal causada por la carga se calcula como `T = m × g`, con `m` en kg y `g ≈ 9,81 m/s²`. Se desprecia aquí el pequeño peso del tramo de correa.

| Masa suspendida total | Tensión ideal aproximada |
| --- | --- |
| 500 g | 4,91 N |
| 600 g | 5,89 N |
| 700 g | 6,87 N |

**600 g es una comprobación especialmente útil porque produce una tensión cercana a 6 N.** Comparar ese valor con la estimación de la calculadora y repetir quitando y reinstalando la herramienta. Una sola comprobación no certifica la exactitud ni permite asegurar una tolerancia de ±0,5 N.

### Si la estimación se desvía o varía demasiado

Primero revisar el cero, el espesor ingresado, la punta, las holguras y cómo se sostiene la herramienta. Si las lecturas son repetibles pero la conversión se desvía, realizar **Calculation Model Calibration** según BIQU: [2]

1. Preparar las cargas de **500 a 2000 g, en incrementos de 100 g**.
2. Tomar **12 mediciones por carga**, retirando y reinstalando el Belter cada vez.
3. Registrar los resultados en la [planilla oficial](https://github.com/bigtreetech/Belter-belt-tension-Tool/blob/master/Calculation%20Tool/BIQU_Belter_Calibration_Data.xlsx).
4. La planilla elimina el máximo y el mínimo y calcula el promedio de las 10 lecturas restantes.
5. Pegar los promedios en **Fit Parameters from Test Data** de la calculadora.
6. Comprobar nuevamente una carga conocida para evaluar el resultado.

No sustituir el modelo actual por la fórmula lineal de una tabla antigua encontrada en comentarios. BIQU utiliza actualmente un modelo no lineal y permite ajustar sus parámetros a las mediciones propias. [2]

## 6. Medir las dos correas de la impresora

1. Apagar la impresora y dejar enfriar la cámara. Medir siempre en condiciones térmicas comparables.
2. Elegir una posición reproducible del cabezal y anotarla. Mantenerla para medir las dos correas y para las comprobaciones posteriores.
3. Colocar el Belter sobre **una sola correa**, en un tramo libre y recto, con espacio suficiente para sus apoyos y la punta. Seguir la orientación de la imagen **Belt Tension Measurement** de BIQU. [2]
4. Evitar que la herramienta toque la otra correa, una polea, el bastidor o un tensor. Sostenerla sin tirar longitudinalmente de la correa ni forzar el cabezal.
5. Medir y repetir retirando y reinstalando el Belter. Si los valores cambian mucho, corregir el montaje antes de ajustar la tensión.
6. Introducir las lecturas de las dos correas en **Compare Belts**, usando la misma calibración y el mismo espesor si ambas correas son iguales.
7. Anotar la tensión estimada de cada una y la diferencia porcentual.

El Belter tiene una distancia propia entre apoyos. El requisito de **150 mm** corresponde a las referencias acústicas citadas; no es un requisito publicado por BIQU para su método de medición.

## 7. Aplicar el objetivo provisional y ajustar

**Si se adopta la referencia provisional de esta guía**, usar **6,0 N por correa**, con ambas dentro de **5,5–6,5 N**. No sumar las dos lecturas ni dividir el objetivo entre dos. Esta interpretación individual se basa en el testimonio de uso con Belter; la wiki por sí sola no la define inequívocamente. [1][3]

1. En la calculadora seleccionar **Custom Range** e introducir mínimo **5,5 N** y máximo **6,5 N**. Esto configura la comparación; no calibra la herramienta ni convierte el objetivo en una especificación oficial. [2]
2. Identificar la revisión del mecanismo y consultar las imágenes de [XY Axis Belt Tension de Creality](https://wiki.creality.com/en/k1-flagship-series/k1-series-general-documents/xy-axis-belt-tension). La guía distingue variantes con y sin tornillos laterales M3×12. [1]
3. Aflojar los tornillos de fijación indicados para permitir el movimiento del tensor. Realizar cambios pequeños de posición y volver a fijarlo antes de medir. No asumir que dejar actuar los resortes produce exactamente 6 N.
4. Después de cada ajuste, mover suavemente el cabezal y regresar a la posición de medición. **Volver a medir ambas correas**, porque ajustar una puede afectar a la otra. [7]
5. Repetir hasta obtener lecturas estables, cercanas entre sí y dentro del rango adoptado.

BIQU considera equilibradas las dos correas cuando su diferencia es **10 % o menor**. Usar el indicador de **Compare Belts** y procurar acercar las lecturas tanto como permita la repetibilidad de la herramienta. No perseguir diferencias de centésimas de N si las mediciones fluctúan más que eso. [2]

Si no es posible llegar al rango sin perder la fijación correcta del tensor, aparecen rozamientos o el cabezal se mueve mal, detener el ajuste y revisar el montaje. No modificar el mecanismo para alcanzar un número cuya aplicación a esa revisión no está confirmada.

## 8. Verificación después del ajuste

1. Comprobar que las correas están correctamente encaminadas y que no rozan ni tienen bordes deshilachados.
2. Revisar la fijación de los tensores y mover suavemente el cabezal por su recorrido para detectar trabas.
3. Encender la impresora y ejecutar la **optimización de vibraciones / Input Shaping** disponible en su configuración. Creality indica volver a realizarla en su procedimiento de diagnóstico de ringing. [9]
4. Hacer una impresión de comprobación con esquinas y círculos; revisar desplazamientos de capas, ringing y geometría.
5. Conservar las lecturas junto con la posición del cabezal, las condiciones térmicas y la calibración del Belter.

Una medición dentro del rango no descarta otros problemas de geometría, poleas, guías o configuración de impresión.

### Registro de mediciones

| Fecha | Condición térmica | Posición del cabezal y tramo | Calibración Belter (mm) | Espesor (mm) | Correa A (N) | Correa B (N) | Diferencia (%) | Resultado de impresión |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | | |

## 9. Errores que conviene evitar

- Ajustar el Belter a **6 mm** pensando que eso representa **6 N**.
- Copiar lecturas de otro instrumento o de otra calibración del cero.
- Considerar que **110 Hz equivale siempre a 6 N**, independientemente de la correa y del tramo.
- Tensar más solo porque el rango genérico GT2 de la calculadora no aparece en verde.
- Confundir la fuerza aplicada para doblar una correa con su tensión longitudinal.
- Colgar un peso de la correa instalada y tratar ese peso como una medición de su tensión existente.
- Dar por seguro el rango absoluto sin comprobar antes la conversión del Belter.

## 📚 Fuentes y archivos

1. [Creality Wiki — XY Axis Belt Tension](https://wiki.creality.com/en/k1-flagship-series/k1-series-general-documents/xy-axis-belt-tension). [Versión china](https://wiki.creality.com/zh/k1-flagship-series/k1-series-general-documents/xy-axis-belt-tension). Rango publicado y mecanismos de ajuste.
2. [BIQU Wiki — Belter](https://global.bttwiki.com/belter.html) y [calculadora actual](https://belter.bttwiki.com/). Calibración, medición, comparación y ajuste del modelo con cargas conocidas.
3. [Facebook — Hey team! K1 max belt tensioning](https://www.facebook.com/groups/967787307995469/posts/1704934860947373/). Testimonio indexado sobre 6,0 ± 0,5 N y uso de Belter; no se pudo consultar la publicación completa ni verificar la respuesta original de soporte.
4. [Reddit — I suck at tensioning... Anyone know what numbers I should be looking for with this tool on the K1?](https://www.reddit.com/r/crealityk1/comments/1ebqnnc/). Consulta específica sobre Belter, discrepancias de conversión y comprobación con pesos.
5. [Creality Forum — Bad dimensional accuracy... on K1C](https://forum.creality.com/t/bad-dimensional-accuracy-first-layer-over-extruded-and-other-layers-under-extruded-on-k1c-a-nightmare/25534). Experiencia de usuario con Belter y lecturas posteriores al ajuste.
6. [Creality Forum — How to set belt tension on K1 Max?](https://forum.creality.com/t/how-to-set-belt-tension-on-k1-max/24797). Referencia comunitaria de aproximadamente 110 Hz, en una consulta con tramo de 150 mm.
7. [Voron Documentation — Secondary Printer Tuning / Belt Tension](https://docs.vorondesign.com/tuning/secondary_printer_tuning.html#belt-tension). Método acústico y equivalencia para su propia configuración; no constituye una especificación para K1 Max.
8. [BIGTREETECH — Belter-belt-tension-Tool](https://github.com/bigtreetech/Belter-belt-tension-Tool). STEP, STL del cero y planilla de calibración.
9. [Creality Forum — K1/K1 Max Printing Ringing Trouble Shooting](https://forum.creality.com/t/k1-k1-max-printing-ringing-trouble-shooting/1451). Revisión del mecanismo y repetición de la optimización de vibraciones.

---

[← Volver al índice](./README.md)
