# Usage

Create `.env` with the following content:
```bash	
MYIP_TOKEN=your_token
MYIP_MM_USER=your_maxmind_user
MYIP_MM_KEY=your_maxmind_key
MYIP_PORT=8888
# Download database once (not on every restart)
MYIP_DB_ONCE=1  
# Set to 1 to refresh database without starting the app (default: 0)
MYIP_DB_REFRESH_ONLY=0
# Let's Encrypt for HTTPS, you must adjust also docker-compose.yaml
MYIP_SSL_KEY=<path-to-letsencrypt-privkey.pem>  #  optional
MYIP_SSL_FULLCHAIN=<path-to-letsencrypt-fullchain.pem>  # optional
```

Run the following commands:
```bash
sudo apt install make
make build      # Build the Docker image
make refresh    # Refresh the MaxMind database (if needed)
make run        # Dev: run the node app (foreground)
make start      # start the app container (daemon)
make stop       # stop the app container (daemon)
make restart    # restart the app container (daemon)
```

Use the following command to get the IP ASN:
```bash	
header="Authorization: Bearer your_token"
wget -qO- --no-check-certificate --header="${header}" http://localhost:8888
curl -sk http://localhost:8888 -H "${header}"
# Outputs: 
# {"ip":"your_ip","asn":"your_asn"}
# {"error":"Not found"}
```

# References

* https://dev.maxmind.com/geoip/updating-databases
* https://www.maxmind.com/en/accounts/current/geoip/downloads
