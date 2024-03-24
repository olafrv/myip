# Usage

Create `.env` with the following content:
```bash	
MYIP_TOKEN=your_token
MYIP_MM_USER=your_maxmind_user
MYIP_MM_KEY=your_maxmind_key
MYIP_PORT=8888
```

Run the following commands:
```bash
sudo apt install make
make            # install, download and start
make install    # only install packages needes
make download   # delete old and download new maxmind db
make run        # run the node app (foreground)
make run.docker # run the node app container (foreground)
make start      # start the app container (daemon)
make stop       # stop the app container (daemon)
make restart    # restart the app container (daemon)
```

# References

* https://dev.maxmind.com/geoip/updating-databases
* https://www.maxmind.com/en/accounts/current/geoip/downloads
