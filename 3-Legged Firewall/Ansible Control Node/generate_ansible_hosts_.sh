#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-input.txt}"
OUTPUT_FILE="${2:-./hosts}"
SSH_KEY="${3:-$HOME/.ssh/id_ed25519}"
ANSIBLE_USER="${4:-vagrant}"
BECOME_PASS="${5:-vagrant}"
PYTHON_INTERPRETER="${6:-/usr/bin/python3}"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Errore: file di input non trovato: $INPUT_FILE" >&2
    exit 1
fi

{
    echo "[all]"

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" ]] && continue

        name="$(sed -n 's/^\([A-Za-z0-9_-]*\)_hostonly_ip[[:space:]]*=[[:space:]]*".*"/\1/p' <<< "$line")"
        ip="$(sed -n 's/^[A-Za-z0-9_-]*_hostonly_ip[[:space:]]*=[[:space:]]*"\([0-9.]*\)"/\1/p' <<< "$line")"

        [[ -z "$name" || -z "$ip" ]] && continue

        echo "$name ansible_host=$ip"
    done < "$INPUT_FILE"

    echo
    echo "[internet]"
    echo "internet-fw"

    echo
    echo "[internal]"
    echo "internal-fw"

    echo
    echo "[subnet_a]"
    echo "subnet_a-nginx"

    echo
    echo "[subnet_b]"
    echo "subnet_b-vm-01"

    echo
    echo "[dmz]"
    echo "dmz-db"
    echo "dmz-honeypot"
    echo "dmz-wazuh"
    echo "dmz-suricata"

    echo
    echo "[all:vars]"
    echo "ansible_user=$ANSIBLE_USER"
    echo "ansible_ssh_private_key_file=$SSH_KEY"
    echo "ansible_become=true"
    echo "ansible_become_method=sudo"
    echo "ansible_become_pass=$BECOME_PASS"
    echo "ansible_python_interpreter=$PYTHON_INTERPRETER"

} > "$OUTPUT_FILE"

echo "Inventory generato in: $OUTPUT_FILE"
echo
cat "$OUTPUT_FILE"
echo

if command -v ansible >/dev/null 2>&1; then
    echo "Test connettivita Ansible..."
    ansible all -i "$OUTPUT_FILE" -m ping
else
    echo "Ansible non trovato nel PATH. Inventory creato, ma test non eseguito."
fi