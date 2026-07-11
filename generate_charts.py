import os
import numpy as np
import matplotlib.pyplot as plt

os.makedirs('/Users/adrian.marino/development/3d-printer-manual/images', exist_ok=True)

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

def plot_horizontal_bars(title, data, labels, xlabel, filename, color_map='viridis', reverse_color=False, suffix=''):
    fig, ax = plt.subplots(figsize=(9, 5.5))
    sorted_indices = np.argsort(data)
    sorted_data = [data[i] for i in sorted_indices]
    sorted_labels = [labels[i] for i in sorted_indices]
    
    try:
        cmap = plt.colormaps[color_map]
    except:
        cmap = plt.cm.viridis
        
    color_range = np.linspace(0.4, 0.9, len(data))
    if reverse_color:
        color_range = color_range[::-1]
    colors = cmap(color_range)
    
    bars = ax.barh(sorted_labels, sorted_data, color=colors, edgecolor='none', height=0.55)
    
    for bar in bars:
        width = bar.get_width()
        val_str = f"{width:.1f}" if width % 1 != 0 else f"{int(width)}"
        label_text = f" {val_str}{suffix}"
        
        if filename == 'impact_strength.png':
            y_index = int(round(bar.get_y()))
            if y_index >= 0 and y_index < len(sorted_labels):
                y_label = sorted_labels[y_index]
                if "No rompe" in y_label or "Nylon" in y_label or "TPU" in y_label or "PP" in y_label:
                    label_text = " >500 J/m (No rompe)"
                    
        ax.text(width, bar.get_y() + bar.get_height()/2, label_text, va='center', ha='left', fontsize=9.5, fontweight='bold', color='#2c3e50')
                
    ax.set_title(title, pad=15, fontweight='bold', color='#2c3e50')
    ax.set_xlabel(xlabel, labelpad=10, fontweight='bold', color='#34495e')
    
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#bdc3c7')
    ax.spines['bottom'].set_color('#bdc3c7')
    ax.grid(True, axis='x', linestyle='--', alpha=0.5)
    
    plt.tight_layout()
    plt.savefig(os.path.join('/Users/adrian.marino/development/3d-printer-manual/images', filename), dpi=300, bbox_inches='tight')
    plt.close()


def create_matrix(x_data, y_data, size_data, color_data, title, xlabel, ylabel, clabel, size_legend_title, filename, x_lim, y_lim, custom_offsets, cmap='YlOrRd', size_multiplier=1.5, size_base=80, size_max=600):
    fig, ax = plt.subplots(figsize=(10.5, 7.5))
    plot_sizes = np.clip(np.array(size_data) * size_multiplier, size_base, size_max)
    
    sc = ax.scatter(x_data, y_data, s=plot_sizes, c=color_data, cmap=cmap, alpha=0.75, edgecolors='#2c3e50', linewidth=1.2)
    
    for i, txt in enumerate(materials):
        clean_txt = txt.split(' ')[0]
        offset = custom_offsets.get(txt, (0.5, 0))
        has_arrow = abs(offset[0]) > (x_lim[1]-x_lim[0])*0.05 or abs(offset[1]) > (y_lim[1]-y_lim[0])*0.05
        ax.annotate(
            clean_txt, (x_data[i], y_data[i]),
            xytext=(x_data[i] + offset[0], y_data[i] + offset[1]),
            fontsize=9.5, fontweight='bold', color='#2c3e50',
            arrowprops=dict(arrowstyle="->", color='#95a5a6', lw=0.8, alpha=0.5) if has_arrow else None
        )
        
    ax.set_title(title, pad=20, fontweight='bold', color='#2c3e50')
    ax.set_xlabel(xlabel, labelpad=10, fontweight='bold', color='#34495e')
    ax.set_ylabel(ylabel, labelpad=10, fontweight='bold', color='#34495e')
    ax.set_xlim(x_lim)
    ax.set_ylim(y_lim)
    
    cbar = plt.colorbar(sc, ax=ax, pad=0.03, shrink=0.8)
    cbar.set_label(clabel, labelpad=10, fontweight='bold', color='#34495e')
    
    for size_val, label in zip([np.min(size_data), np.median(size_data), np.max(size_data)], ["Bajo", "Medio", "Alto/Extremo"]):
        ax.scatter([], [], c='#bdc3c7', alpha=0.6, s=np.clip(size_val * size_multiplier, size_base, size_max), label=label, edgecolors='#7f8c8d')
    
    legend = ax.legend(title=size_legend_title, loc="upper left", frameon=True, facecolor='#ffffff', edgecolor='#bdc3c7')
    legend.get_title().set_fontweight('bold')
    
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#bdc3c7')
    ax.spines['bottom'].set_color('#bdc3c7')
    ax.grid(True, linestyle='--', alpha=0.4)
    
    plt.tight_layout()
    plt.savefig(os.path.join('/Users/adrian.marino/development/3d-printer-manual/images', filename), dpi=300, bbox_inches='tight')
    plt.close()


materials = [
    'PEEK', 'PA-CF (Nylon+Carbono)', 'PETG-CF (PETG+Carbono)', 'PC (Policarbonato)', 'Nylon (PA)', 
    'PLA', 'PETG', 'ASA', 'ABS', 'TPU (Flexible)', 'HIPS', 'PP (Polipropileno)'
]

tensile = [95, 95, 80, 70, 60, 57, 50, 45, 39, 35, 32, 28]
impact = [65, 100, 70, 325, 520, 20, 90, 185, 175, 520, 85, 520]
thermal = [160, 150, 80, 115, 110, 55, 78, 98, 98, 50, 75, 98]
printability = [0.5, 3, 4, 1, 2, 10, 8, 5, 4, 6, 6, 2]

plot_horizontal_bars("Resistencia a la Tracción de Filamentos 3D", tensile, materials, "Resistencia a la Tracción (MPa) - Mayor es mejor", "tensile_strength.png", color_map='plasma', reverse_color=True, suffix=' MPa')
plot_horizontal_bars("Resistencia al Impacto de Filamentos 3D", impact, materials, "Resistencia al Impacto (J/m) - Mayor es mejor", "impact_strength.png", color_map='viridis', reverse_color=True, suffix=' J/m')
plot_horizontal_bars("Resistencia Térmica de Filamentos (Temperatura de Deflexión - HDT)", thermal, materials, "Temperatura de Deflexión Térmica (°C a 0.45 MPa) - Mayor es mejor", "thermal_resistance.png", color_map='inferno', reverse_color=True, suffix=' °C')
plot_horizontal_bars("Facilidad de Impresión de Filamentos 3D", printability, materials, "Escala de Facilidad (1 = Extremo, 10 = Muy Fácil)", "printability.png", color_map='viridis', reverse_color=False, suffix='/10')

# 5.1 Matriz: Facilidad de Impresión vs Tracción
offsets_1 = {'PEEK': (0.35, -1.0), 'PA-CF (Nylon+Carbono)': (0.35, 0.5), 'PETG-CF (PETG+Carbono)': (-1.9, -1.5), 'PC (Policarbonato)': (0.35, -1.0), 'Nylon (PA)': (0.35, 0.5), 'PLA': (0.3, -1.5), 'PETG': (-0.7, 1.5), 'ASA': (0.3, 1.0), 'ABS': (-0.6, -2.5), 'TPU (Flexible)': (0.3, -2.0), 'HIPS': (0.3, 1.0), 'PP (Polipropileno)': (-1.8, -2.0)}
create_matrix(printability, tensile, impact, thermal, "Matriz General: Resistencia vs. Facilidad de Impresión", "Facilidad de Impresión (1 = Extremo, 10 = Muy Fácil)", "Resistencia a la Tracción (MPa)", "Resistencia Térmica (HDT, °C)", "Resistencia al Impacto", "decision_matrix_general.png", (-0.5, 11), (20, 110), offsets_1, cmap='YlOrRd')

# 5.2 Matriz: Entornos Duros (Térmica vs Impacto)
offsets_2 = {'PEEK': (3, -10), 'PA-CF (Nylon+Carbono)': (3, -20), 'PC (Policarbonato)': (3, -20), 'Nylon (PA)': (-10, 20), 'PETG': (3, 10), 'ASA': (3, -20), 'ABS': (-12, -20), 'TPU (Flexible)': (3, -20), 'HIPS': (3, -20), 'PP (Polipropileno)': (-15, -30), 'PLA': (3, -10), 'PETG-CF (PETG+Carbono)': (3, -15)}
create_matrix(thermal, impact, tensile, printability, "Matriz de Entornos Duros: Térmica vs. Impacto", "Resistencia Térmica (HDT, °C)", "Resistencia al Impacto (J/m)", "Facilidad de Impresión (1-10)", "Resistencia Tracción", "decision_matrix_harsh.png", (40, 175), (0, 560), offsets_2, cmap='RdYlGn', size_multiplier=5)

# 5.3 Matriz: Comportamiento Mecánico (Tracción vs Impacto)
offsets_3 = {'PEEK': (-5, -30), 'PA-CF (Nylon+Carbono)': (-5, -40), 'PC (Policarbonato)': (-5, 20), 'Nylon (PA)': (2, 10), 'PLA': (2, -10), 'PETG': (2, 20), 'ABS': (-5, -40), 'ASA': (2, -20), 'TPU (Flexible)': (2, -30), 'HIPS': (-8, -30), 'PP (Polipropileno)': (-8, -40), 'PETG-CF (PETG+Carbono)': (-8, 20)}
create_matrix(tensile, impact, thermal, printability, "Matriz Mecánica: Tracción vs. Impacto (Rigidez vs. Tenacidad)", "Resistencia a la Tracción (MPa) [Rigidez/Carga]", "Resistencia al Impacto (J/m) [Tenacidad/Golpes]", "Facilidad de Impresión (1-10)", "Resistencia Térmica", "decision_matrix_mechanical.png", (20, 105), (0, 560), offsets_3, cmap='RdYlGn', size_multiplier=3)

print("Matrices generadas correctamente.")
