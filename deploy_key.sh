#!/usr/bin/env bash

# Script per copiare la chiave pubblica su tutte le macchine elencate in un file di input (creato con l'output di terraform apply).
# Il file di input deve contenere righe con il formato:
# <nome_macchina>_hostonly_ip = "<indirizzo_ip>"
# Esempio di file di input:
#
# dmz-db_hostonly_ip = "192.168.56.xxx"
# dmz-honeypot_hostonly_ip = "192.168.56.xxx"
# dmz-suricata_hostonly_ip = "192.168.56.xxx"
# dmz-wazuh_hostonly_ip = "192.168.56.xxx"
# internal-fw_hostonly_ip = "192.168.56.xxx"
# internet-fw_hostonly_ip = "192.168.56.xxx"
# subnet_a-nginx_hostonly_ip = "192.168.56.xxx"
# subnet_b-vm-01_hostonly_ip = "192.168.56.xxx"

# Esempio di utilizzo:
#   ./deploy_key.sh input.txt

set -euo pipefail

KEY_FILE="$HOME/.ssh/id_ed25519.pub"    # Percorso della chiave pubblica da copiare
SSH_KEY="$HOME/.ssh/vagrant_insecure"   # Chiave privata per l'accesso alle macchine (modifica se necessario)
USER="vagrant"

# Legge da stdin o da file passato come argomento
INPUT="${1:-/dev/stdin}"

grep -oE '"([0-9]{1,3}\.){3}[0-9]{1,3}"' "$INPUT" | tr -d '"' | while read -r ip; do
    echo ">>> Copio chiave su $ip"

    ssh -o StrictHostKeyChecking=no \
        -i "$SSH_KEY" \
        "$USER@$ip" \
        "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" \
        < "$KEY_FILE"

    echo "OK $ip"
done