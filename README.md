# Usage

Create .env file with the following content:
```bash	
MYIP_TOKEN=your_token
MYIP_MM_USER=your_maxmind_user
MYIP_MM_KEY=your_maxmind_key
```

Run the following commands:
```bash
npm install
mkdir dbs
nodejs download.js
find dbs -type d -name 'GeoLite2-ASN_*' -exec rm -rf {} \;
tar xvfz dbs/GeoLite2-ASN.tar.gz -C dbs
cp dbs/GeoLite2-ASN_*/*.mmdb dbs/
nodejs app.js
docker compose up --build
docker compose up -d --build
```