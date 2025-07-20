#!/bin/bash

set -e  # Exit on error

cd /usr/src/app  # Change to the application directory

env | grep MYIP_DB

if [ "$MYIP_DB_REFRESH_ONLY" == "1" ] \
    || [ "$MYIP_DB_ONCE" != "1" ] \
    || [ ! -f "dbs/downloaded" ] 
then
    echo "Downloading GeoLite2 database..."
    # ls -l
    node download.js  # download GeoLite2-ASN.tar.gz

    echo "Processing database files..."
    find dbs -type d -name 'GeoLite2-ASN_*' | xargs -r rm -rf
    tar xzf dbs/GeoLite2-ASN.tar.gz -C dbs/
    cp dbs/GeoLite2-ASN_*/*.mmdb dbs/
    echo 1 > dbs/downloaded
fi

if [ ! -f "dbs/GeoLite2-ASN.mmdb" ]
then
    echo "Error: GeoLite2-ASN.mmdb not found!"
    exit 1
else
    echo "GeoLite2-ASN.mmdb found and ready to use."
fi

if [ "$MYIP_DB_REFRESH_ONLY" != "1" ]
then
    echo "Starting the application..."
    exec node app.js
fi