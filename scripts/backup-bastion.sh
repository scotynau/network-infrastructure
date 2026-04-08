#!/bin/bash

# ==============================================================================
# Bastion Backup Script - scotynau.tech
# Description: Packs Wireguard and Nginx configs into a timestamped tarball.
# Author: scotynau
# ==============================================================================

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: Este script debe ejecutarse como root (sudo)."
   exit 1
fi

# Configuration
BACKUP_DIR="/tmp/bastion_backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="bastion_backup_$TIMESTAMP.tar.gz"
OUTPUT_FILE="$BACKUP_DIR/$BACKUP_NAME"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "--- Iniciando backup del Bastión ($TIMESTAMP) ---"

# Target directories/files
# Añadimos /etc/wireguard, /etc/nginx y la config de Velocity si existe
TARGETS="/etc/wireguard /etc/nginx"

# Add Velocity config if it exists in a standard path (ajustar si es necesario)
if [ -d "/home/soptech/velocity" ]; then
    TARGETS="$TARGETS /home/soptech/velocity/*.toml"
fi

# Create tarball
# p: preserve permissions (clave para las keys de Wireguard)
tar -czpf "$OUTPUT_FILE" $TARGETS 2>/dev/null

if [ $? -eq 0 ]; then
    echo "SUCCESS: Backup creado correctamente en $OUTPUT_FILE"
    echo "TIP: Mueve este archivo a tu repositorio privado 'network-ops-private' y haz un push."
    
    # Set owner to the regular user so you can move it easily later
    # Ajustamos al usuario soptech (cambiar si usas otro en el bastión)
    CURRENT_USER=$(logname)
    chown $CURRENT_USER:$CURRENT_USER "$OUTPUT_FILE"
else
    echo "ERROR: Hubo un problema al crear el backup."
    exit 1
fi

echo "--- Backup Finalizado ---"
