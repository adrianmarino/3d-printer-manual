import os
import numpy as np
import matplotlib.pyplot as plt

# Crear directorio de imágenes si no existe
os.makedirs('images', exist_ok=True)

# Configuración global de estilo segura y moderna
try:
    plt.style.use('seaborn-v0_8-whitegrid')
except:
    try:
        plt.style.use('ggplot')
    except:
        pass

plt.rcParams.update({
    'font.sans-serif': 'Arial',
    'font.family': 'sans-serif',
    'font.size': 10,
    'axes.labelsize': 11,
    'axes.titlesize': 13,
    'xtick.labelsize': 9,
    'ytick.labelsize': 10,
    'figure.titlesize': 15
})

# Función para generar gráficos de barras horizontales profesionales
def plot_horizontal_bars(title, data, labels, xlabel, filename, color_map='viridis', reverse_color=False, suffix=''):
    fig, ax = plt.subplots(figsize=(9, 5.5))
    
    # Ordenar los datos de menor a mayor para que el mejor quede arriba
    sorted_indices = np.argsort(data)
    sorted_data = [data[i] for i in sorted_indices]
    sorted_labels = [labels[i] for i in sorted_indices]
    
    # Crear gradiente de color basado en la paleta seleccionada
    try:
        cmap = plt.colormaps[color_map]
    except:
        cmap = plt.cm.viridis
        
    color_range = np.linspace(0.4, 0.9, len(data))
    if reverse_color:
        color_range = color_range[::-1]
    colors = cmap(color_range)
    
    bars = ax.barh(sorted_labels, sorted_data, color=colors, edgecolor='none', height=0.55)
    
    # Agregar etiquetas con los valores a la derecha de cada barra
    for bar in bars:
        width = bar.get_width()
        val_str = f"{width:.1f}" if width % 1 != 0 else f"{int(width)}"
        
        label_text = f" {val_str}{suffix}"
        
        # Ajuste específico para materiales de impacto que no rompen (se grafican como 520 de valor representativo)
        if filename == 'impact_strength.png':
            y_index = int(round(bar.get_y()))
            if y_index >= 0 and y_index < len(sorted_labels):
                y_label = sorted_labels[y_index]
                if "No rompe" in y_label or "Nylon" in y_label or "TPU" in y_label or "PP" in y_label:
                    label_text = " >500 J/m (No rompe)"
                    
        ax.text(width, bar.get_y() + bar.get_height()/2, label_text, 
                va='center', ha='left', fontsize=9.5, fontweight='bold', color='#2c3e50')
                
    ax.set_title(title, pad=15, fontweight='bold', color='#2c3e50')
    ax.set_xlabel(xlabel, labelpad=10, fontweight='bold', color='#34495e')
    
    # Limpiar bordes innecesarios para diseño plano minimalista
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#bdc3c7')
    ax.spines['bottom'].set_color('#bdc3c7')
    ax.grid(True, axis='x', linestyle='--', alpha=0.5)
    
    plt.tight_layout()
    plt.savefig(os.path.join('images', filename), dpi=300, bbox_inches='tight')
    plt.close()

# Listado completo de materiales
materials = [
    'PEEK', 'PA-CF (Nylon+Carbono)', 'PETG-CF (PETG+Carbono)', 'PC (Policarbonato)', 'Nylon (PA)', 
    'PLA', 'PETG', 'ASA', 'ABS', 'TPU (Flexible)', 'HIPS', 'PP (Polipropileno)'
]

# 1. Gráfico de Resistencia a la Tracción (MPa)
tensile = [95, 95, 80, 70, 60, 57, 50, 45, 39, 35, 32, 28]
plot_horizontal_bars(
    "Resistencia a la Tracción de Filamentos 3D",
    tensile, materials, "Resistencia a la Tracción (MPa) - Mayor es mejor", "tensile_strength.png",
    color_map='plasma', reverse_color=True, suffix=' MPa'
)

# 2. Gráfico de Resistencia al Impacto (J/m)
# Capamos el valor para representación de TPU, Nylon y PP que no rompen a 520
impact = [65, 100, 70, 325, 520, 20, 90, 185, 175, 520, 85, 520]
plot_horizontal_bars(
    "Resistencia al Impacto de Filamentos 3D",
    impact, materials, "Resistencia al Impacto (J/m) - Mayor es mejor", "impact_strength.png",
    color_map='viridis', reverse_color=True, suffix=' J/m'
)

# 3. Gráfico de Resistencia Térmica (HDT, °C)
thermal = [160, 150, 80, 115, 110, 55, 78, 98, 98, 50, 75, 98]
plot_horizontal_bars(
    "Resistencia Térmica de Filamentos (Temperatura de Deflexión - HDT)",
    thermal, materials, "Temperatura de Deflexión Térmica (°C a 0.45 MPa) - Mayor es mejor", "thermal_resistance.png",
    color_map='inferno', reverse_color=True, suffix=' °C'
)

# 4. Gráfico de Facilidad de Impresión (1-10)
printability = [0.5, 3, 4, 1, 2, 10, 8, 5, 4, 6, 6, 2]
plot_horizontal_bars(
    "Facilidad de Impresión de Filamentos 3D",
    printability, materials, "Escala de Facilidad (1 = Extremo, 10 = Muy Fácil)", "printability.png",
    color_map='viridis', reverse_color=False, suffix='/10'
)

print("Gráficos generados correctamente en la carpeta './images'")
