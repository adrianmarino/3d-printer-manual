#!/usr/bin/env bash
# ==============================================================================
# restore-k1-max.sh — Restaurar configuraciones K1 Max después de actualización
# ==============================================================================
# Uso:
#   ./restore-k1-max.sh <directorio-backup>
#
# Ejemplo:
#   ./restore-k1-max.sh ~/k1-max-backups/20260808_123456
#
# Ejecutar desde la máquina local (NO desde la impresora).
# ==============================================================================

set -euo pipefail

# --- Configuración -----------------------------------------------------------
PRINTER_IP="192.168.2.100"
PRINTER_USER="root"
PRINTER_PORT="22"
SSH_PASS="creality_2023"

# Rutas remotas
REMOTE_CONFIG_DIR="/usr/data/printer_data/config"
REMOTE_HELPER_DIR="/usr/data/helper-script"

# --- Colores -----------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Funciones ---------------------------------------------------------------
log()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
info()  { echo -e "${CYAN}[i]${NC} $1"; }

ssh_cmd() {
    sshpass -p "$SSH_PASS" ssh -p "$PRINTER_PORT" \
        -o ConnectTimeout=10 \
        -o StrictHostKeyChecking=no \
        -o ServerAliveInterval=5 \
        -o ServerAliveCountMax=3 \
        "$PRINTER_USER@$PRINTER_IP" "$@"
}

scp_cmd() {
    sshpass -p "$SSH_PASS" scp -P "$PRINTER_PORT" \
        -o ConnectTimeout=10 \
        -o StrictHostKeyChecking=no \
        -o ServerAliveInterval=5 \
        -o ServerAliveCountMax=3 \
        -r "$@"
}

# --- Verificar conexión y backup ---------------------------------------------
check_args() {
    if [[ $# -lt 1 ]]; then
        error "Uso: $0 <directorio-backup>"
        echo ""
        echo "Ejemplo:"
        echo "  $0 ~/k1-max-backups/20260808_123456"
        echo ""
        echo "Backups disponibles:"
        ls -d ~/k1-max-backups/*/ 2>/dev/null || echo "  (ninguno)"
        exit 1
    fi

    BACKUP_DIR="$1"

    if [[ ! -d "$BACKUP_DIR" ]]; then
        error "Directorio de backup no existe: $BACKUP_DIR"
        exit 1
    fi

    if [[ ! -f "$BACKUP_DIR/manifest.txt" ]]; then
        warn "No se encontró manifest.txt — verifica que sea un backup válido"
    fi
}

check_connection() {
    info "Verificando conexión con la impresora..."
    if ! ssh_cmd "echo 'OK'" &>/dev/null; then
        error "No se pudo conectar a $PRINTER_IP:$PRINTER_PORT"
        exit 1
    fi
    log "Conexión establecida"
}

# --- Pre-restore check -------------------------------------------------------
check_firmware_version() {
    info "Verificando firmware actual..."
    local current_version
    # Versión REAL: /etc/ota_info (el comentario en printer.cfg es stale)
    current_version=$(ssh_cmd "cat /etc/ota_info 2>/dev/null | grep ota_version | awk -F'=' '{print \$2}'" 2>/dev/null || echo "desconocido")
    local backup_version
    if [[ -f "$BACKUP_DIR/printer-data/ota_info" ]]; then
        backup_version=$(grep "ota_version" "$BACKUP_DIR/printer-data/ota_info" | awk -F'=' '{print $2}' || echo "desconocido")
    else
        backup_version=$(grep "Version:" "$BACKUP_DIR/config/printer.cfg" 2>/dev/null | head -1 || echo "desconocido")
    fi

    echo "  Firmware actual: $current_version"
    echo "  Firmware backup: $backup_version"
    echo ""

    if [[ "$current_version" != "$backup_version" ]]; then
        warn "El firmware ha cambiado desde el backup"
        warn "Esto es esperado si acabas de actualizar"
    fi
}

# --- Restore de configuraciones ----------------------------------------------
restore_config() {
    info "Restaurando configuraciones principales..."
    local backup_cfg="$BACKUP_DIR/config"
    local remote_cfg="$REMOTE_CONFIG_DIR"

    # Verificar si hay nuevas configuraciones del firmware
    # Comparar versión REAL (ota_info) — el comentario en printer.cfg es stale
    local has_new_config=false
    local remote_ver
    remote_ver=$(ssh_cmd "cat /etc/ota_info 2>/dev/null | grep ota_version" 2>/dev/null || echo "")
    local backup_ver
    backup_ver=$(grep "ota_version" "$BACKUP_DIR/printer-data/ota_info" 2>/dev/null || echo "")

    if [[ -n "$remote_ver" && -n "$backup_ver" && "$remote_ver" != "$backup_ver" ]]; then
        has_new_config=true
        warn "El firmware tiene configuraciones nuevas que podrían ser importantes"
        warn "Se crearán archivos de comparación para que revises"
    fi

    # Archivos a restaurar
    local files=(
        "printer.cfg"
        "gcode_macro.cfg"
        "printer_params.cfg"
        "sensorless.cfg"
        "moonraker.conf"
        "octoeverywhere.conf"
        "octoeverywhere-system.cfg"
    )

    for f in "${files[@]}"; do
        if [[ -f "$backup_cfg/$f" ]]; then
            # Si hay config nueva, guardar comparación
            if $has_new_config && ssh_cmd "test -f '$remote_cfg/$f'" 2>/dev/null; then
                ssh_cmd "cp '$remote_cfg/$f' '$remote_cfg/$f.firmware-new'" 2>/dev/null
            fi

            scp_cmd "$backup_cfg/$f" "$PRINTER_USER@$PRINTER_IP:$remote_cfg/$f" 2>/dev/null && \
                log "  → $f restaurado" || warn "  → Error restaurando $f"
        else
            warn "  → $f no encontrado en backup (skip)"
        fi
    done

    # .theme
    if [[ -d "$backup_cfg/.theme" ]]; then
        scp_cmd "$backup_cfg/.theme/" "$PRINTER_USER@$PRINTER_IP:$remote_cfg/.theme/" 2>/dev/null && \
            log "  → .theme/ restaurado"
    fi
}

# --- Restore de Helper-Script ------------------------------------------------
restore_helper_script() {
    info "Restaurando Helper-Script..."
    local backup_helper="$BACKUP_DIR/helper-script"
    local remote_cfg="$REMOTE_CONFIG_DIR"

    # Restaurar archivos de configuración de KAMP, timelapse, M600
    local helper_files=(
        "Helper-Script/timelapse.cfg"
        "Helper-Script/M600-support.cfg"
        "Helper-Script/KAMP/KAMP_Settings.cfg"
    )

    for f in "${helper_files[@]}"; do
        if [[ -f "$backup_helper/$f" ]]; then
            scp_cmd "$backup_helper/$f" "$PRINTER_USER@$PRINTER_IP:$remote_cfg/$f" 2>/dev/null && \
                log "  → $f restaurado" || warn "  → Error restaurando $f"
        fi
    done

    # Verificar symlinks
    local symlink_status
    symlink_status=$(ssh_cmd "ls -la '$remote_cfg/Helper-Script/' 2>/dev/null" || echo "")
    if [[ -n "$symlink_status" ]]; then
        log "  Symlinks verificados:"
        echo "$symlink_status" | grep "\->" | while read -r line; do
            echo "    $line"
        done
    fi

    # Si Helper-Script fue eliminado, reinstallarlo
    if ! ssh_cmd "test -d '$REMOTE_HELPER_DIR'" 2>/dev/null; then
        warn "  Helper-Script no encontrado — reinstalando..."
        ssh_cmd "wget --no-check-certificate -O - https://raw.githubusercontent.com/Guilouz/Creality-K1-and-K1-Max/main/Scripts/installer.sh | bash" 2>/dev/null && \
            log "  Helper-Script reinstalado" || warn "  Error reinstalando Helper-Script"
    fi
}

# --- Restore de Moonraker ----------------------------------------------------
restore_moonraker() {
    info "Verificando Moonraker..."
    # Moonraker se restaura con la config principal

    # Verificar que moonraker está corriendo
    if ssh_cmd "pgrep -f moonraker" &>/dev/null; then
        log "  Moonraker está corriendo"
    else
        warn "  Moonraker no está corriendo — intentando reiniciar..."
        ssh_cmd "sudo systemctl restart moonraker" 2>/dev/null || \
            ssh_cmd "supervisorctl restart moonraker" 2>/dev/null || \
            warn "  No se pudo reiniciar Moonraker manualmente"
    fi
}

# --- Restore de servicios ----------------------------------------------------
restore_services() {
    info "Verificando servicios..."

    # Lista de servicios esperados
    local services=("klipper" "moonraker" "mainsail" "octoeverywhere")

    for svc in "${services[@]}"; do
        local status
        status=$(ssh_cmd "supervisorctl status $svc 2>/dev/null | awk '{print \$2}'" 2>/dev/null || echo "UNKNOWN")
        case "$status" in
            RUNNING)  log "  $svc: OK" ;;
            STOPPED)  warn "  $svc: DETENIDO" ;;
            *)        warn "  $svc: $status" ;;
        esac
    done
}

# --- Verificar configuración restaurada --------------------------------------
verify_restore() {
    info "Verificando integridad de configuración..."

    # Verificar que printer.cfg no está vacío
    local cfg_size
    cfg_size=$(ssh_cmd "wc -c < '$REMOTE_CONFIG_DIR/printer.cfg'" 2>/dev/null || echo "0")
    if [[ "$cfg_size" -lt 100 ]]; then
        error "printer.cfg parece corrupto ($cfg_size bytes)"
        error "Usando respaldo: printer.cfg.firmware-new si existe"
        ssh_cmd "test -f '$REMOTE_CONFIG_DIR/printer.cfg.firmware-new' && cp '$REMOTE_CONFIG_DIR/printer.cfg.firmware-new' '$REMOTE_CONFIG_DIR/printer.cfg'"
    else
        log "  printer.cfg: $cfg_size bytes — OK"
    fi

    # Verificar que gcode_macro.cfg no está vacío
    local macro_size
    macro_size=$(ssh_cmd "wc -c < '$REMOTE_CONFIG_DIR/gcode_macro.cfg'" 2>/dev/null || echo "0")
    if [[ "$macro_size" -lt 50 ]]; then
        warn "  gcode_macro.cfg parece vacío o corrupto ($macro_size bytes)"
    else
        log "  gcode_macro.cfg: $macro_size bytes — OK"
    fi

    # Verificar symlinks rotos
    local broken
    broken=$(ssh_cmd "find '$REMOTE_CONFIG_DIR' -type l ! -exec test -e {} \; -print 2>/dev/null" || echo "")
    if [[ -n "$broken" ]]; then
        warn "  Symlinks rotos detectados:"
        echo "$broken" | while read -r link; do
            echo "    $link"
        done
    else
        log "  Symlinks: todos OK"
    fi
}

# --- Crear archivo de comparación --------------------------------------------
create_diff_report() {
    local backup_cfg="$BACKUP_DIR/config"
    local remote_cfg="$REMOTE_CONFIG_DIR"

    info "Generando reporte de diferencias..."
    local diff_report="$BACKUP_DIR/diff-report.txt"
    local tmp_dir="$BACKUP_DIR/.firmware-new-local"
    mkdir -p "$tmp_dir"

    {
        echo "=== Diferencias entre Backup y Firmware Actual ==="
        echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        for f in printer.cfg gcode_macro.cfg moonraker.conf; do
            if [[ -f "$backup_cfg/$f" ]] && ssh_cmd "test -f '$remote_cfg/$f.firmware-new'" 2>/dev/null; then
                # Traer el archivo nuevo localmente y comparar (diff remoto no ve rutas locales)
                scp_cmd "$PRINTER_USER@$PRINTER_IP:$remote_cfg/$f.firmware-new" "$tmp_dir/$f" 2>/dev/null
                echo "--- $f ---"
                diff "$backup_cfg/$f" "$tmp_dir/$f" 2>/dev/null || true
                echo ""
            fi
        done
    } > "$diff_report" 2>/dev/null

    rm -rf "$tmp_dir"

    if [[ -s "$diff_report" ]]; then
        log "Reporte de diferencias: $diff_report"
        warn "Revisa las diferencias con: cat $diff_report"
    fi
}

# --- Reiniciar Klipper -------------------------------------------------------
restart_klipper() {
    info "Reiniciando Klipper..."
    ssh_cmd "sudo systemctl restart klipper" 2>/dev/null || \
        ssh_cmd "supervisorctl restart klipper" 2>/dev/null || \
        warn "No se pudo reiniciar Klipper automáticamente"

    sleep 3

    if ssh_cmd "pgrep -f klippy" &>/dev/null; then
        log "Klipper reiniciado correctamente"
    else
        warn "Klipper puede no estar corriendo — verifica manualmente"
    fi
}

# --- Resumen final -----------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Restauración completada${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Backup usado: ${YELLOW}$BACKUP_DIR${NC}"
    echo ""
    echo -e "  Próximos pasos:"
    echo -e "  1. Abre Mainsail: ${CYAN}http://$PRINTER_IP${NC}"
    echo -e "  2. Verifica que todo funciona correctamente"
    echo -e "  3. Imprime una pieza de prueba"
    echo ""
    echo -e "  Si algo falla:"
    echo -e "  - Los archivos .firmware-new están en $REMOTE_CONFIG_DIR/"
    echo -e "  - Puedes comparar con: diff printer.cfg printer.cfg.firmware-new"
    echo ""
}

# --- Main --------------------------------------------------------------------
main() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  K1 Max Restore — $(date '+%Y-%m-%d %H:%M')${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo ""

    check_args "$@"
    check_connection
    check_firmware_version

    # Confirmación
    echo ""
    read -p "¿Restaurar configuraciones desde $BACKUP_DIR? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Cancelado."
        exit 0
    fi

    restore_config
    restore_helper_script
    restore_moonraker
    restore_services
    verify_restore
    create_diff_report
    restart_klipper
    print_summary
}

main "$@"
