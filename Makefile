include .env
export

default: run

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