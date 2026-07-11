# Guía de Resistencia de Filamentos de Impresión 3D

Al diseñar piezas para impresión 3D, elegir el material correcto es fundamental para garantizar su viabilidad mecánica. A continuación, se presenta un análisis detallado, tablas comparativas y gráficos visuales de las propiedades mecánicas de la gama completa de filamentos disponibles en el mercado.

> **Nota sobre la Anisotropía:** Las piezas impresas en 3D (FDM/FFF) son anisotrópicas. Esto significa que la resistencia mecánica varía según la dirección de los esfuerzos respecto a la orientación de las capas. Una pieza siempre será mucho más débil en el eje Z (separación entre capas) que en los ejes X e Y (dirección del filamento extruido).

---

## 📊 Gráficos Comparativos de Rendimiento (Visual)

### 1. Resistencia a la Tracción (MPa)
*Mide la capacidad de soportar fuerzas de estiramiento y cargas pesadas antes de romperse (promedios en MPa, eje X-Y).*

```text
PEEK (Polímero Industrial) : █████████████████████████████████ 95 MPa
PA-CF (Nylon + Carbono)    : ███████████████████████████████ 95 MPa
PETG-CF (PETG + Carbono)   : ██████████████████████████ 80 MPa
PC (Policarbonato)         : ███████████████████████ 70 MPa
Nylon (PA)                 : ████████████████████ 60 MPa
PLA                        : ███████████████████ 57 MPa
PETG                       : ████████████████ 50 MPa
ASA                        : ███████████████ 45 MPa
ABS                        : █████████████ 39 MPa
TPU (Flexible)             : ███████████ 35 MPa
HIPS                       : ██████████ 32 MPa
PP (Polipropileno)         : ████████ 28 MPa
```

### 2. Resistencia al Impacto (J/m)
*Mide la capacidad de absorber energía y resistir golpes directos, caídas y choques repentinos sin quebrarse (promedios en J/m).*

```text
TPU (Flexible)             : ██████████████████████████████ 500+ J/m (No rompe)
PP (Polipropileno)         : ██████████████████████████████ 500+ J/m (No rompe)
Nylon (PA)                 : ██████████████████████████████ 500+ J/m (Extrema)
PC (Policarbonato)         : ███████████████████ 325 J/m
ASA                        : ███████████ 185 J/m
ABS                        : ██████████ 175 J/m
PA-CF (Nylon + Carbono)    : ██████ 100 J/m
PETG                       : █████ 90 J/m
HIPS                       : █████ 85 J/m
PETG-CF (PETG + Carbono)   : ████ 70 J/m
PEEK (Polímero Industrial) : ████ 65 J/m
PLA                        : █ 20 J/m
```

### 3. Resistencia Térmica (Temperatura de Deflexión - HDT a 0.45 MPa)
*Mide la temperatura a partir de la cual el material comienza a ablandarse y deformarse bajo carga estática.*

```text
PEEK (Polímero Industrial) : ████████████████████████████████ 160 °C (Cristalizado: >250 °C)
PA-CF (Nylon + Carbono)    : ██████████████████████████████ 150 °C
PC (Policarbonato)         : ███████████████████████ 115 °C
Nylon (PA)                 : ██████████████████████ 110 °C
ABS                        : ████████████████████ 98 °C
ASA                        : ████████████████████ 98 °C
PP (Polipropileno)         : ████████████████████ 98 °C
PETG-CF (PETG + Carbono)   : ████████████████ 80 °C
PETG                       : ████████████████ 78 °C
HIPS                       : ███████████████ 75 °C
PLA                        : ███████████ 55 °C
TPU (Flexible)             : ██████████ 50 °C
```

### 4. Facilidad de Impresión (Escala 1 al 10)
*Evaluación de la dificultad de impresión (adhesión, warping, exigencia de hardware, control de humedad).*

```text
PLA                        : ██████████████████████████████ 10/10 (Muy fácil)
PETG                       : ████████████████████████ 8/10 (Fácil)
HIPS                       : ███████████████████ 6/10 (Media)
TPU (Flexible)             : ██████████████████ 6/10 (Media-Flexible)
ASA                        : ███████████████ 5/10 (Media-Warping)
PETG-CF (PETG + Carbono)   : ██████████████ 4/10 (Abrasivo)
ABS                        : ████████████ 4/10 (Difícil-Warping)
PA-CF (Nylon + Carbono)    : █████████ 3/10 (Muy difícil - Abrasivo)
PP (Polipropileno)         : ██████ 2/10 (Alta contracción)
Nylon (PA)                 : ██████ 2/10 (Complejo - Higroscópico)
PC (Policarbonato)         : ███ 1/10 (Extremo - Warping y Temperatura)
PEEK (Polímero Industrial) : █ 0.5/10 (Grado Industrial - Requisitos de cámara)
```

---

## 📋 Tabla Comparativa Completa de Propiedades

| Material | Resistencia a la Tracción (MPa) | Resistencia al Impacto (J/m) | Resistencia Térmica (HDT, °C) | Facilidad de Impresión | Características Clave y Aplicaciones |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **PLA** | 50 – 65 *(Alta)* | 15 – 25 *(Muy Baja)* | ~55 °C | 10 / 10 | Rígido y frágil. Excelente para prototipos visuales y piezas decorativas rápidas. |
| **PETG** | 45 – 55 *(Media-Alta)* | 60 – 120 *(Media)* | ~78 °C | 8 / 10 | Muy versátil. Excelente resistencia química, tenaz y con poca contracción. |
| **ABS** | 33 – 45 *(Media)* | 150 – 200 *(Alta)* | ~98 °C | 4 / 10 | Tenaz y ligero. Fácil de post-procesar (lijar/acetona). Sufre de *warping* severo. |
| **ASA** | 40 – 50 *(Media)* | 160 – 210 *(Alta)* | ~98 °C | 5 / 10 | Excelente para exteriores. Resistente a rayos UV e intemperie. Similar al ABS pero con menor contracción. |
| **Nylon (PA)** | 45 – 75 *(Alta)* | > 500 *(Extrema)* | ~110 °C | 2 / 10 | Súper tenaz y flexible. Gran resistencia al desgaste y fatiga. Altamente higroscópico. |
| **Policarbonato (PC)** | 65 – 75 *(Muy Alta)* | 250 – 400 *(Extrema)* | ~115 °C | 1 / 10 | Piezas estructurales extremas. Combina alta rigidez con resistencia de impacto masiva. |
| **TPU** | 30 – 40 *(Baja)* | No rompe *(Absorción)*| ~50 °C | 6 / 10 | Elastómero flexible. Ideal para juntas, bujes, protectores y amortiguadores de impacto. |
| **PA-CF** | 80 – 110 *(Extrema)* | 80 – 120 *(Media)* | ~150 °C | 3 / 10 | Nylon reforzado con carbono. Súper ligero, ultra rígido y estable térmicamente. Muy abrasivo. |
| **PETG-CF** | 70 – 90 *(Muy Alta)* | 60 – 80 *(Baja)* | ~80 °C | 4 / 10 | PETG reforzado con carbono. Mayor rigidez estructural que el PETG común con buena facilidad de impresión. |
| **HIPS** | 30 – 35 *(Baja)* | 75 – 100 *(Media)* | ~75 °C | 6 / 10 | Utilizado principalmente como material de soporte soluble (en limoneno) para ABS. |
| **PP** | 25 – 32 *(Baja)* | No rompe *(Extrema)* | ~98 °C | 2 / 10 | Excelente fatiga mecánica (bisagras vivas) y resistencia química. Muy difícil adherir a la cama. |
| **PEEK** | 90 – 100 *(Extrema)* | 60 – 70 *(Media)* | ~160 °C | 0.5 / 10 | Grado aeroespacial y médico. Máxima resistencia química y mecánica. Requiere hardware especializado. |

---

## 🧠 Análisis de Selección: ¿Qué material usar según el esfuerzo?

### 1. Para soportar cargas estáticas sin flectar (Rigidez y Tracción)
*   **Ganador:** **PA-CF** o **PEEK**. 
*   **Alternativa accesible:** **PETG-CF** o **PLA** (en ambientes <50 °C).
*   *Análisis:* La fibra de carbono refuerza la matriz del plástico haciéndolo inmóvil ante cargas axiales de tracción. Si la pieza no va a superar temperaturas moderadas, el PLA tiene una rigidez sorprendente a un precio extremadamente bajo.

### 2. Para soportar golpes directos e impactos repetitivos (Tenacidad)
*   **Ganador:** **Nylon (PA)**, **TPU** o **PP**.
*   **Alternativa rígida:** **Policarbonato (PC)** o **ABS**.
*   *Análisis:* El Nylon y el PP absorben el impacto deformándose microscópicamente de forma elástica y recuperando su forma sin romperse. Si necesitas que la pieza sea rígida y no se mueva, pero aun así soporte caídas fuertes, el **Policarbonato (PC)** es insuperable.

### 3. Para soportar flexión elástica y fatiga (Ganchos, Clips, Bisagras)
*   **Ganador:** **PP (Polipropileno)** o **Nylon (PA)**.
*   **Alternativa común:** **PETG**.
*   *Análisis:* El PP permite crear bisagras funcionales de una sola pieza que pueden doblarse miles de veces sin sufrir fatiga estructural. El Nylon ofrece un comportamiento similar con mayor dureza. El PETG es excelente para clips a presión cotidianos. El PLA se fracturará de inmediato ante esfuerzos de flexión.

### 4. Resistencia a la intemperie y rayos UV (Uso en Exterior)
*   **Ganador:** **ASA**.
*   *Análisis:* La radiación solar y la lluvia degradan la mayoría de plásticos (el ABS se vuelve quebradizo, el PLA se deforma mecánicamente y absorbe humedad). El ASA está formulado específicamente para soportar radiación UV sin perder sus propiedades mecánicas ni decolorarse.

### 5. Resistencia a Altas Temperaturas continuas
*   **Ganador:** **PEEK** o **PA-CF**.
*   **Alternativa común:** **ABS** o **ASA**.
*   *Análisis:* Si la pieza va a ir dentro del compartimento de un motor o cerca de un foco de calor, el PLA fallará catastróficamente de inmediato. El ABS/ASA aguantan cerca del límite del agua hirviendo (~100 °C), pero el PA-CF y el PEEK se mantienen estables en aplicaciones de ingeniería pesada superando los 150 °C de forma continua.