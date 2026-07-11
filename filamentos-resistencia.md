# Guía de Resistencia de Filamentos de Impresión 3D

Al diseñar piezas para impresión 3D, elegir el material correcto es fundamental para garantizar su viabilidad mecánica. A continuación, se presenta un análisis detallado y una tabla comparativa de las propiedades mecánicas de los filamentos más comunes.

> **Nota sobre la Anisotropía:** Las piezas impresas en 3D (FDM/FFF) son anisotrópicas. Esto significa que la resistencia mecánica varía según la dirección de los esfuerzos respecto a la orientación de las capas. Una pieza siempre será mucho más débil en el eje Z (separación entre capas) que en los ejes X e Y (dirección del filamento extruido).

## Tabla Comparativa de Propiedades Mecánicas

| Material | Resistencia a la Tracción (MPa)<br>*(Soportar estiramiento)* | Resistencia a la Flexión (MPa)<br>*(Soportar doblado)* | Resistencia al Impacto<br>*(Soportar golpes, J/m)* | Rigidez / Módulo Flexural<br>*(Deformación antes de ruptura)* |
| :--- | :---: | :---: | :---: | :--- |
| **PLA** | 50 – 65 *(Alta)* | 80 – 100 *(Alta)* | 15 – 25 *(Muy Baja)* | **Extrema**. Muy rígido; no se dobla, se quiebra de golpe (frágil). |
| **PETG** | 45 – 55 *(Media-Alta)* | 60 – 75 *(Media)* | 60 – 120 *(Media)* | **Moderada**. Tiene cierta elasticidad antes de la ruptura. |
| **ABS** | 33 – 45 *(Media)* | 60 – 70 *(Media)* | 150 – 200 *(Alta)* | **Baja-Media**. Se dobla considerablemente antes de romperse. |
| **ASA** | 40 – 50 *(Media)* | 65 – 75 *(Media)* | 160 – 210 *(Alta)* | **Baja-Media**. Similar al ABS pero con excelente resistencia a rayos UV. |
| **Nylon (PA)** | 45 – 75 *(Alta)* | 50 – 85 *(Media)* | > 500 *(Extrema, sin rotura)* | **Muy Baja**. Muy flexible y tenaz; absorbe impactos deformándose. |
| **Policarbonato (PC)** | 65 – 75 *(Muy Alta)* | 90 – 110 *(Muy Alta)* | 250 – 400 *(Extrema)* | **Alta**. Combina una rigidez estructural enorme con alta tenacidad. |
| **TPU (Flexible)** | 30 – 40 *(Baja)* | N/A *(Se dobla por completo)*| **Absorción total** | **Nula**. Es un elastómero. |
| **PA-CF (Nylon + Carbono)**| 80 – 110 *(Extrema)* | 120 – 150 *(Extrema)* | 80 – 120 *(Media)* | **Extrema**. La fibra aporta rigidez masiva, pero lo vuelve más frágil al impacto que el PA puro. |

## Análisis de Rendimiento: ¿Cuál elegir según el esfuerzo?

### 1. Para soportar cargas constantes sin deformarse (Tracción y Rigidez)
*   **Ganador:** **PLA** (en entornos de menos de 50°C) o **PA-CF / PETG** (para ambientes más cálidos o esfuerzos sostenidos).
*   *Consideración:* Aunque el PLA soporta más peso estático que el ABS, sufre de deformación plástica progresiva ("creep") bajo estrés constante y fallará catastróficamente si sufre un impacto o exceso de temperatura.

### 2. Para soportar golpes, caídas y vibraciones (Impacto)
*   **Ganador:** **Nylon (PA)** o **TPU**.
*   Si necesitas que la pieza mantenga su forma estructural (rígida) pero que no se haga pedazos al recibir un golpe, el **ABS**, **ASA** o el **Policarbonato (PC)** son las mejores opciones. El Nylon es el rey de la resistencia a golpes, pero se flexiona demasiado bajo cargas pesadas.

### 3. Para soportar flexión repetitiva (Palancas, Ganchos, Clips a presión)
*   **Ganador:** **PETG** o **Nylon**.
*   El PETG ofrece el mejor equilibrio para piezas mecánicas comunes: se dobla bajo tensión y recupera su forma sin romperse. El PLA, por el contrario, se quebra inmediatamente al intentar flexionarlo. El ABS soporta flexión pero sufre fatiga más rápido que el PETG.

### 4. Uso de Ingeniería Avanzada o Extrema
*   **Ganador:** **Policarbonato (PC)**.
*   Es el material de impresión 3D FDM más fuerte en términos generales. Soporta tracción severa, gran flexión y resiste impactos violentos. *Desventaja:* Requiere de impresoras de grado industrial (fusores de más de 280°C y cámaras cerradas/calefaccionadas).