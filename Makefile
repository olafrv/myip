NODE_VERSION := 24.15.0
PNPM_VERSION := 11.1.2
NVM_VERSION  := 0.40.4

export NODE_VERSION
export PNPM_VERSION

include .env
export

.PHONY: install sync build run refresh start stop restart

default: run

install: ## Install nvm, Node.js, pnpm, and project dependencies
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash
	bash -c '. "$$HOME/.nvm/nvm.sh" && nvm install && nvm use && node -v && corepack enable pnpm && pnpm -v && pnpm install'

sync: ## Sync versions into .nvmrc and package.json
	@echo "$(NODE_VERSION)" > .nvmrc
	@node -e " \
		const fs = require('fs'); \
		const p = JSON.parse(fs.readFileSync('package.json', 'utf8')); \
		p.engines = p.engines || {}; \
		p.engines.node = '$(NODE_VERSION)'; \
		p.engines.pnpm = '$(PNPM_VERSION)'; \
		p.packageManager = 'pnpm@$(PNPM_VERSION)'; \
		fs.writeFileSync('package.json', JSON.stringify(p, null, 2) + '\n'); \
	"
	@echo "Synced: node=$(NODE_VERSION) pnpm=$(PNPM_VERSION)"

build:
	docker compose build

run:
	docker compose up

refresh:
	MYIP_DB_REFRESH_ONLY=1 docker compose up --abort-on-container-exit

start:
	docker compose up -d

stop:
	docker compose down

restart: stop start
