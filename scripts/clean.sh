#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-config.env}"
if [[ -f "$CONFIG_FILE" ]]; then
  set -a
  source "$CONFIG_FILE"
  set +a
fi

systemctl stop llama-server 2>/dev/null || true
systemctl disable llama-server 2>/dev/null || true
rm -f /etc/systemd/system/llama-server.service
systemctl daemon-reload

if [[ -n "${LLAMA_CPP_DIR:-}" ]]; then
  rm -rf "$LLAMA_CPP_DIR"
fi

if [[ -n "${MODEL_DIR:-}" ]]; then
  rm -rf "$MODEL_DIR"
fi

echo "Cleaned service, llama.cpp directory, and model directory."
