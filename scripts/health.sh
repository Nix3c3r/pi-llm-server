#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-config.env}"
source "$CONFIG_FILE"

curl -sS "http://127.0.0.1:${PORT}/v1/models" | python3 -m json.tool
