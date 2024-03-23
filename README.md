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
make            # install, download and run
make install    # only install node modules
make download   # download maxmind database (delete the old one first)
make run        # run the application in the host
make run.docker # run the application in a docker container
```

# References

* https://dev.maxmind.com/geoip/updating-databases
* https://www.maxmind.com/en/accounts/current/geoip/downloads
