# Usage

Create .env file with the following content:
```bash	
MYIP_TOKEN=your_token
MYIP_MM_USER=your_maxmind_user
MYIP_MM_KEY=your_maxmind_key
```

Run the following commands:
```bash
apt install make
make            # install, download and run
make install    # only install node modules
make download   # download maxmind database
make run        # run the application
make run.docker # run the application in a docker container
```
