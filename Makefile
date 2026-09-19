# Both versions below are DERIVED, so neither is written out twice.
#   Node: .nvmrc is the single source of truth (PNPM_SECURITY.md -> "Node
#     version - single source of truth"). Bump it, run `make sync`, commit both.
#   pnpm: package.json's packageManager field is the source of truth
#     (PNPM_SECURITY.md -> "Keep pnpm updated via the packageManager field +
#     Corepack"). Bump it with `corepack use pnpm@<version>`, which also writes
#     the integrity hash. Parsed with sed, not node, so `make install` still
#     works before a Node runtime exists.
NODE_VERSION := $(shell cat .nvmrc)
PNPM_VERSION := $(shell sed -n 's/.*"packageManager": *"pnpm@\([0-9.]*\).*/\1/p' package.json)
NVM_VERSION  := 0.40.4

export NODE_VERSION
export PNPM_VERSION

include .env
export

.PHONY: cert install sync build run refresh start stop restart test

default: run

cert: ## Generate self-signed TLS certificate for localhost testing
	mkdir -p tmp
	openssl req -x509 -newkey rsa:2048 \
		-keyout tmp/localhost-pk.pem \
		-out tmp/localhost-fc.pem \
		-days 365 -nodes \
		-subj "/CN=localhost" \
		-addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

install: ## Install nvm, Node.js, pnpm, and project dependencies
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash
	bash -c '. "$$HOME/.nvm/nvm.sh" && nvm install && nvm use && node -v && corepack enable pnpm && pnpm -v && pnpm install'

sync: ## Regenerate engines.node from .nvmrc
	@pnpm run sync:node-pin
	@echo "Synced: node=$(NODE_VERSION) pnpm=$(PNPM_VERSION)"

build:
	docker compose build

run: build
	docker compose up

refresh:
	MYIP_DB_REFRESH_ONLY=1 docker compose up --abort-on-container-exit

start: build
	docker compose up -d

stop:
	docker compose down

restart: stop start

test: start ## Build, start, and test the API
	@SSL_KEY="$${MYIP_SSL_KEY:-./tmp/localhost-pk.pem}"; \
	if [ -f "$$SSL_KEY" ]; then PROTO=https; else PROTO=http; fi; \
	URL="$$PROTO://localhost:$(MYIP_PORT)"; \
	echo "Waiting for $$URL ..."; \
	for i in $$(seq 1 30); do \
		if curl -sk "$$URL" -o /dev/null 2>/dev/null; then break; fi; \
		echo "  waiting... ($$i/30)"; \
		sleep 2; \
	done; \
	echo "==> $$URL"; \
	echo "--- Authorized (expect 200):"; \
	curl -sk -w "\nHTTP %{http_code}\n" -H "Authorization: Bearer $(MYIP_TOKEN)" "$$URL"; \
	echo "--- Unauthorized (expect 403):"; \
	curl -sk -w "\nHTTP %{http_code}\n" "$$URL"
