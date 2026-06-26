#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-config.env}"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

systemctl stop llama-server 2>/dev/null || true
systemctl disable llama-server 2>/dev/null || true
rm -f /etc/systemd/system/llama-server.service
systemctl daemon-reload

echo "Uninstalled systemd service. Model and llama.cpp files were kept. Run 'make clean' to remove them."
