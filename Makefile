SHELL := /bin/bash
CONFIG ?= config.env
include $(CONFIG)
export

.PHONY: install uninstall clean status logs restart health

install:
	@sudo ./scripts/install.sh "$(CONFIG)"

uninstall:
	@sudo ./scripts/uninstall.sh "$(CONFIG)"

clean:
	@sudo ./scripts/clean.sh "$(CONFIG)"

status:
	@systemctl status llama-server --no-pager || true

logs:
	@journalctl -u llama-server -f

restart:
	@sudo systemctl restart llama-server

health:
	@./scripts/health.sh "$(CONFIG)"
