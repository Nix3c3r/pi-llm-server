# pi-llm-server

Minimal Raspberry Pi 5 LLM server repo for hosting a local GGUF model with `llama.cpp`.

This repo installs, configures, and runs an OpenAI-compatible local LLM endpoint.

## Target setup

- Raspberry Pi 5, 8GB RAM
- Raspberry Pi OS Lite 64-bit
- SSD storage recommended
- Active cooling recommended
- Some service runs elsewhere and calls this Pi over LAN

## Quick start

```bash
git clone <your-repo-url> pi-llm-server
cd pi-llm-server
cp config.example.env config.env
nano config.env
make install
make status
make health
```

The API endpoint will be:

```text
http://<pi-ip>:8080/v1/chat/completions
```

## Configuration

Edit `config.env` before installing. If it does not exist, take a copy from `config.example.env`

Important values:

```env
LLAMA_USER=pi
LLAMA_CPP_DIR=/opt/llama.cpp
MODEL_DIR=/opt/llm-models
MODEL_URL=https://huggingface.co/Qwen/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q4_K_M.gguf
MODEL_FILE=qwen3-1.7b-q4_k_m.gguf
HOST=0.0.0.0
PORT=8080
CONTEXT_SIZE=2048
THREADS=4
EXTRA_ARGS=
```

Recommended model for transaction classification:

- `Qwen3-1.7B-Instruct GGUF Q4_K_M` for speed
- `Qwen3-1.7B-Instruct GGUF Q8_0` for better quality if performance is acceptable

## Commands

```bash
make install     # install dependencies, build llama.cpp, download model, install/start service
make uninstall   # stop and remove systemd service, keep model and llama.cpp
make clean       # remove service, llama.cpp, and downloaded models
make status      # show service status
make logs        # follow service logs
make restart     # restart llama-server
make health      # query /v1/models locally
```

## Test request

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "local",
    "temperature": 0,
    "messages": [
      {"role": "system", "content": "Return only valid JSON."},
      {"role": "user", "content": "Classify transaction: PAYPAL *NETFLIX, -12.99 EUR. Categories: Groceries, Rent, Subscriptions, Transport."}
    ]
  }'
```

## Notes

`make uninstall` intentionally keeps downloaded/build files so reinstalling is fast.

`make clean` deletes everything managed by this repo under `LLAMA_CPP_DIR` and `MODEL_DIR`.

If the service crashes or the Pi reboots, systemd restarts it automatically.


## Project Status

This project exists because I wanted a simple, reproducible way to run a local LLM server on a Raspberry Pi for my own home lab.

It is shared publicly in case others find it useful, but it is not intended to be a fully supported product.