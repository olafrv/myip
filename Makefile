include .env
export

all: install run

install:
	sudo apt-get install -y nodejs
	npm install

download:
	mkdir -p dbs
	nodejs download.js
	find dbs -type d -name 'GeoLite2-ASN_*' | xargs -n1 rm -v -i -rf
	tar xvfz dbs/GeoLite2-ASN.tar.gz -C dbs
	cp dbs/GeoLite2-ASN_*/*.mmdb dbs/

run: download
	npm update
	nodejs app.js

run.docker: download
	docker compose up --build
