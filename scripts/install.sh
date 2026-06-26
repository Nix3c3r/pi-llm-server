#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-config.env}"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config file: $CONFIG_FILE" >&2
  exit 1
fi

set -a
source "$CONFIG_FILE"
set +a

: "${LLAMA_USER:?}"
: "${LLAMA_CPP_DIR:?}"
: "${MODEL_DIR:?}"
: "${MODEL_URL:?}"
: "${MODEL_FILE:?}"
: "${HOST:?}"
: "${PORT:?}"
: "${CONTEXT_SIZE:?}"
: "${THREADS:?}"

if ! id "$LLAMA_USER" >/dev/null 2>&1; then
  echo "User '$LLAMA_USER' does not exist. Edit config.env or create the user first." >&2
  exit 1
fi

apt-get update
apt-get install -y git cmake build-essential curl ca-certificates libcurl4-openssl-dev

mkdir -p "$MODEL_DIR"
chown -R "$LLAMA_USER:$LLAMA_USER" "$MODEL_DIR"

if [[ ! -d "$LLAMA_CPP_DIR/.git" ]]; then
  git clone https://github.com/ggerganov/llama.cpp "$LLAMA_CPP_DIR"
else
  git -C "$LLAMA_CPP_DIR" pull --ff-only
fi

cmake -S "$LLAMA_CPP_DIR" -B "$LLAMA_CPP_DIR/build" \
  -DGGML_NATIVE=ON \
  -DGGML_OPENMP=ON \
  -DLLAMA_CURL=ON
cmake --build "$LLAMA_CPP_DIR/build" --config Release -j"$(nproc)"

MODEL_PATH="$MODEL_DIR/$MODEL_FILE"
if [[ ! -f "$MODEL_PATH" ]]; then
  echo "Downloading model to $MODEL_PATH"
  curl -L --fail --continue-at - -o "$MODEL_PATH" "$MODEL_URL"
else
  echo "Model already exists: $MODEL_PATH"
fi
chown "$LLAMA_USER:$LLAMA_USER" "$MODEL_PATH"

install -m 0644 systemd/llama-server.service.template /etc/systemd/system/llama-server.service

sed -i \
  -e "s|__LLAMA_USER__|$LLAMA_USER|g" \
  -e "s|__LLAMA_CPP_DIR__|$LLAMA_CPP_DIR|g" \
  -e "s|__MODEL_PATH__|$MODEL_PATH|g" \
  -e "s|__HOST__|$HOST|g" \
  -e "s|__PORT__|$PORT|g" \
  -e "s|__CONTEXT_SIZE__|$CONTEXT_SIZE|g" \
  -e "s|__THREADS__|$THREADS|g" \
  -e "s|__EXTRA_ARGS__|${EXTRA_ARGS:-}|g" \
  /etc/systemd/system/llama-server.service

systemctl daemon-reload
systemctl enable llama-server
systemctl restart llama-server

echo "Installed. Check with: make status"
echo "Endpoint: http://$(hostname -I | awk '{print $1}'):$PORT/v1/chat/completions"
