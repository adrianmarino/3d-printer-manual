#!/usr/bin/env bash
# ==============================================================================
# backup-k1-max.sh — Backup completo de configuraciones K1 Max
# ==============================================================================
# Uso:
#   ./backup-k1-max.sh
#
# Ejecutar desde la máquina local (NO desde la impresora).
# Crea un backup en ~/k1-max-backups/<timestamp>/
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
REMOTE_PRINTER_DATA="/usr/data/printer_data"
REMOTE_TIMELAPSE_DIR="/usr/data/printer_data/timelapse"
REMOTE_FRAMES_DIR="/usr/data/printer_data/frames"
REMOTE_OTA_INFO="/etc/ota_info"

# Rutas locales
BACKUP_BASE="$HOME/k1-max-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"

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

# --- Verificar conexión ------------------------------------------------------
check_connection() {
    info "Verificando conexión con la impresora..."
    if ! ssh_cmd "echo 'OK'" &>/dev/null; then
        error "No se pudo conectar a $PRINTER_IP:$PRINTER_PORT"
        error "Verifica que la impresora esté encendida y accesible."
        exit 1
    fi
    log "Conexión establecida con $PRINTER_IP"
}

# --- Crear estructura de backup ----------------------------------------------
setup_backup_dir() {
    info "Creando directorio de backup: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"/{config,helper-script,moonraker,printer-data,timelapse,metadata}
}

# --- Backup de configuraciones principales -----------------------------------
backup_config() {
    info "Respaldando configuraciones principales..."
    local remote="$REMOTE_CONFIG_DIR"
    local local_dir="$BACKUP_DIR/config"

    # Archivos principales (excluyendo backups antiguos printer-YYYYMMDD_HHMMSS.cfg)
    local files=(
        "printer.cfg"
        "gcode_macro.cfg"
        "printer_params.cfg"
        "sensorless.cfg"
        "moonraker.conf"
        "octoeverywhere.conf"
        "octoeverywhere-system.cfg"
        ".moonraker.conf.bkp"
    )

    for f in "${files[@]}"; do
        if ssh_cmd "test -f '$remote/$f'" 2>/dev/null; then
            scp_cmd "$PRINTER_USER@$PRINTER_IP:$remote/$f" "$local_dir/" 2>/dev/null && \
                log "  → $f" || warn "  → Error copiando $f"
        else
            warn "  → $f no encontrado (skip)"
        fi
    done

    # Backup de .theme
    if ssh_cmd "test -d '$remote/.theme'" 2>/dev/null; then
        scp_cmd "$PRINTER_USER@$PRINTER_IP:$remote/.theme/" "$local_dir/.theme/" 2>/dev/null && \
            log "  → .theme/" || warn "  → Error copiando .theme/"
    fi

    # Último printer.cfg válido (el más reciente)
    # Nota: con pipefail, si no hay archivos, fallaría — usar || true
    local latest_cfg
    latest_cfg=$(ssh_cmd "ls -t '$remote'/printer-*.cfg 2>/dev/null | head -1" 2>/dev/null || true)
    if [[ -n "$latest_cfg" ]]; then
        scp_cmd "$PRINTER_USER@$PRINTER_IP:$latest_cfg" "$local_dir/printer-latest.cfg" 2>/dev/null && \
            log "  → printer-latest.cfg (de $(basename "$latest_cfg"))"
    fi
}

# --- Backup de Helper-Script -------------------------------------------------
backup_helper_script() {
    info "Respaldando Helper-Script (Guilouz)..."
    local remote="$REMOTE_HELPER_DIR"
    local local_dir="$BACKUP_DIR/helper-script"

    # Estado del repo (no copiar .git completo — solo info)
    mkdir -p "$local_dir"
    ssh_cmd "cd '$remote' && git log --oneline -5" > "$local_dir/git-log.txt" 2>/dev/null
    ssh_cmd "cd '$remote' && git remote -v" > "$local_dir/git-remote.txt" 2>/dev/null
    log "  → Información de git guardada"

    # Configuración instalada (archivos que Helper-Script puso en config/)
    local helper_cfg_files=(
        "Helper-Script/timelapse.cfg"
        "Helper-Script/M600-support.cfg"
        "Helper-Script/KAMP/KAMP_Settings.cfg"
    )

    for f in "${helper_cfg_files[@]}"; do
        if ssh_cmd "test -e '$REMOTE_CONFIG_DIR/$f'" 2>/dev/null; then
            mkdir -p "$local_dir/$(dirname "$f")"
            scp_cmd "$PRINTER_USER@$PRINTER_IP:$REMOTE_CONFIG_DIR/$f" "$local_dir/$f" 2>/dev/null && \
                log "  → $f" || warn "  → Error copiando $f"
        fi
    done

    # Symlinks info
    ssh_cmd "ls -la '$REMOTE_CONFIG_DIR/Helper-Script/'" > "$local_dir/symlinks-info.txt" 2>/dev/null
    log "  → Información de symlinks guardada"
}

# --- Backup de Moonraker -----------------------------------------------------
backup_moonraker() {
    info "Respaldando Moonraker..."
    local local_dir="$BACKUP_DIR/moonraker"

    # moonraker.conf ya está en config/, aquí guardamos info de versión
    # Nota: usar timeout sobre sshpass directo, NO bash -c (no ve la función ssh_cmd)
    timeout 10 sshpass -p "$SSH_PASS" ssh -p "$PRINTER_PORT" \
        -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
        "$PRINTER_USER@$PRINTER_IP" \
        "pip3 show moonraker 2>/dev/null || pip show moonraker 2>/dev/null" \
        > "$local_dir/moonraker-version.txt" 2>/dev/null || \
        echo "No se pudo obtener versión de Moonraker" > "$local_dir/moonraker-version.txt"
    log "  → moonraker version info guardada"
}

# --- Backup de datos de impresora --------------------------------------------
backup_printer_data() {
    info "Respaldando datos de impresora..."
    local remote="$REMOTE_PRINTER_DATA"
    local local_dir="$BACKUP_DIR/printer-data"

    # moonraker.asvc (servicios registrados)
    scp_cmd "$PRINTER_USER@$PRINTER_IP:$remote/moonraker.asvc" "$local_dir/" 2>/dev/null && \
        log "  → moonraker.asvc" || warn "  → moonraker.asvc no encontrado"

    # UUID
    scp_cmd "$PRINTER_USER@$PRINTER_IP:$remote/.moonraker.uuid" "$local_dir/" 2>/dev/null && \
        log "  → .moonraker.uuid" || warn "  → .moonraker.uuid no encontrado"

    # Versión REAL del firmware (/etc/ota_info) — crítico para restore
    if ssh_cmd "test -f '$REMOTE_OTA_INFO'" 2>/dev/null; then
        scp_cmd "$PRINTER_USER@$PRINTER_IP:$REMOTE_OTA_INFO" "$local_dir/ota_info" 2>/dev/null && \
            log "  → ota_info (firmware real)" || warn "  → Error copiando ota_info"
    else
        warn "  → ota_info no encontrado"
    fi

    # Estado de servicios (solo si supervisorctl está disponible)
    ssh_cmd "command -v supervisorctl >/dev/null 2>&1 && supervisorctl status" > "$local_dir/supervisor-status.txt" 2>/dev/null || \
        ssh_cmd "ps aux" > "$local_dir/process-list.txt" 2>/dev/null || true
    log "  → Estado de servicios guardado"

    # Versiones instaladas
    {
        echo "=== Firmware Version (REAL) ==="
        ssh_cmd "cat /etc/ota_info 2>/dev/null | grep ota_version" 2>/dev/null || echo "N/A"
        echo ""
        echo "=== Firmware Version (comentario printer.cfg) ==="
        ssh_cmd "head -5 /usr/data/printer_data/config/printer.cfg" 2>/dev/null || echo "N/A"
        echo ""
        echo "=== Klipper Version ==="
        ssh_cmd "git -C /usr/data/klipper log --oneline -1 2>/dev/null || cat /usr/share/klipper/klippy/__init__.py 2>/dev/null | head -5" 2>/dev/null || echo "N/A"
        echo ""
        echo "=== Python Version ==="
        ssh_cmd "python3 --version 2>/dev/null || python --version 2>/dev/null" 2>/dev/null || echo "N/A"
        echo ""
        echo "=== Mainsail Version ==="
        ssh_cmd "cat /usr/data/mainsail/package.json 2>/dev/null | grep version" 2>/dev/null || echo "N/A"
    } > "$local_dir/versions.txt" 2>/dev/null
    log "  → Versiones guardadas en versions.txt"
}

# --- Backup de timelapse (opcional, solo metadata) ---------------------------
backup_timelapse() {
    info "Verificando timelapse..."
    local local_dir="$BACKUP_DIR/timelapse"

    # Solo contamos archivos, no copiamos frames (pesan mucho)
    # Nota: || true para evitar que pipefail + set -e mate el script si no hay dir
    local frame_count
    frame_count=$(ssh_cmd "ls '$REMOTE_FRAMES_DIR' 2>/dev/null | wc -l" 2>/dev/null || echo "0")
    local video_count
    video_count=$(ssh_cmd "ls '$REMOTE_TIMELAPSE_DIR'/*.mp4 2>/dev/null | wc -l" 2>/dev/null || echo "0")

    mkdir -p "$local_dir"
    echo "Frames: $frame_count" > "$local_dir/info.txt"
    echo "Videos: $video_count" >> "$local_dir/info.txt"
    log "  → $frame_count frames, $video_count videos (no copiados — pesados)"
}

# --- Backup de espacio en disco ----------------------------------------------
backup_disk_info() {
    info "Verificando espacio en disco..."
    local local_dir="$BACKUP_DIR/metadata"

    mkdir -p "$local_dir"
    ssh_cmd "df -h /usr/data" > "$local_dir/disk-usage.txt" 2>/dev/null
    log "  → Disk usage guardado"

    local used_pct
    used_pct=$(ssh_cmd "df /usr/data | tail -1 | awk '{print \$5}' | tr -d '%'" 2>/dev/null || echo "?")
    if [[ "$used_pct" =~ ^[0-9]+$ ]] && [[ "$used_pct" -gt 90 ]]; then
        warn "  ⚠️  Disco al ${used_pct}% — considera limpiar antes de actualizar"
    fi
}

# --- Crear archivo de metadata del backup ------------------------------------
create_manifest() {
    info "Generando manifiesto del backup..."
    cat > "$BACKUP_DIR/manifest.txt" <<EOF
=== K1 Max Backup Manifest ===
Fecha:      $(date '+%Y-%m-%d %H:%M:%S')
Printer:    $PRINTER_IP
User:       $PRINTER_USER
Backup Dir: $BACKUP_DIR

=== Contenido ===
$(find "$BACKUP_DIR" -type f | sed "s|$BACKUP_DIR/||" | sort)

=== Conteo ===
Archivos: $(find "$BACKUP_DIR" -type f | wc -l)
Tamaño:   $(du -sh "$BACKUP_DIR" | cut -f1)
EOF
    log "Manifiesto creado en $BACKUP_DIR/manifest.txt"
}

# --- Resumen final -----------------------------------------------------------
print_summary() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Backup completado exitosamente${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Ubicación: ${YELLOW}$BACKUP_DIR${NC}"
    echo -e "  Tamaño:    $(du -sh "$BACKUP_DIR" | cut -f1)"
    echo ""
    echo -e "  Para restaurar, ejecuta:"
    echo -e "  ${CYAN}./restore-k1-max.sh $BACKUP_DIR${NC}"
    echo ""
}

# --- Main --------------------------------------------------------------------
main() {
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  K1 Max Backup — $(date '+%Y-%m-%d %H:%M')${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo ""

    check_connection
    setup_backup_dir
    backup_config
    backup_helper_script
    backup_moonraker
    backup_printer_data
    backup_timelapse
    backup_disk_info
    create_manifest
    print_summary
}

main "$@"
