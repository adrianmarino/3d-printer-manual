# 🤖 Repositorio: 3D Printer Manual (Instrucciones para Agentes)

Bienvenido. Si eres un agente de IA colaborando en este repositorio, debes adherirte estrictamente a las siguientes reglas, convenciones de arquitectura de contenido y flujos de trabajo de este proyecto.

---

## 📋 Contexto del Repositorio
Este repositorio (**3d-printer-manual**) es una recopilación abierta de guías, tutoriales y configuraciones prácticas en español para la calibración, optimización, ajuste y mantenimiento de impresoras 3D (con especial foco en Klipper, Mainsail y materiales de ingeniería).

## 📁 Estructura del Proyecto
-   `/*.md` (Raíz): Todas las guías temáticas se alojan en la raíz del repositorio (ej. `bed-mesh-calibration.md`, `filamentos-resistencia.md`).
-   `/images/`: Contiene todos los recursos visuales y gráficos (en formato `.png` principalmente) enlazados por las guías.
-   `/generate_charts.py`: Script de Python con `matplotlib` encargado de procesar la matriz de datos y generar los gráficos comparativos.

---

## 🛠️ Reglas y Convenciones de Contenido

### 1. Idioma y Estilo
-   **Guías y Contenido:** El contenido del manual siempre se escribe en **español** fluido, profesional, técnico y directo.
-   **Nombres de Archivo:** Nombres en minúsculas, usando guiones medios para separar palabras (ej. `filamentos-resistencia.md`).

### 2. Sincronización de Gráficos y Tablas
-   Si modificas o agregas materiales o valores técnicos en la guía de resistencia de filamentos, **debes actualizar correspondientemente la matriz de datos en `generate_charts.py`** y ejecutar el script para regenerar las imágenes en `/images/`:
    ```bash
    python3 generate_charts.py
    ```
-   Nunca utilices caracteres como la virgulilla (`~`) en tablas de temperatura, ya que algunos renderizadores lo muestran de forma confusa similar a un signo menos (`-`), dando a entender temperaturas negativas. Utiliza números enteros directos y especifica "Aproximadamente" o "Aprox." en las cabeceras.

---

## 🚀 Flujo de Trabajo de Git

### 1. Mensajes de Commit
-   **Idioma obligatorio:** Todos los mensajes de commit de Git se deben escribir estrictamente en **inglés**, siguiendo convenciones estándar (ej. `docs: ...`, `fix: ...`, `refactor: ...`).

### 2. Autorización de Operaciones Críticas
-   **Git Push:** NUNCA ejecutes un `git push` de forma automática. Siempre debes solicitar autorización explícita e inequívoca al usuario. Las afirmaciones de flujo amplias como "continuar", "avanzar" o "adelante" **no** se interpretan como autorización para empujar código al repositorio remoto.
