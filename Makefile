include .env
export

all: install download start

install:
	sudo apt-get install -y nodejs npm
	npm install

download:
	mkdir -p dbs
	nodejs download.js \
	&& find dbs -type d -name 'GeoLite2-ASN_*' | xargs -n1 rm -v -i -rf \
	&& tar xvfz dbs/GeoLite2-ASN.tar.gz -C dbs/ \
	&& cp dbs/GeoLite2-ASN_*/*.mmdb dbs/ || echo "Maxmind DB download error!"
	test -f dbs/GeoLite2-ASN.mmdb 

run:
	npm update > /dev/null
	nodejs app.js

run.docker:
	docker compose up --build

start:
	docker compose up -d --build

stop:
	docker compose down

restart: stop start