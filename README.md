# myip

A simple Node.js API to get client IP address and ASN.

## Setup

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
# TLS cert paths (optional; defaults to self-signed cert for localhost testing)
MYIP_SSL_KEY=<path-to-letsencrypt-privkey.pem>
MYIP_SSL_FULLCHAIN=<path-to-letsencrypt-fullchain.pem>
```

Install Node.js, nvm, pnpm, and project dependencies (versions pinned in [Makefile](Makefile)):

```bash
sudo apt install make
make install  # Install nvm, Node.js, pnpm, and project dependencies
```

For localhost testing, generate a self-signed TLS certificate (stored in `tmp/`, gitignored):

```bash
make cert
```

The certificate defaults are pre-wired in `docker-compose.yaml` (`MYIP_SSL_KEY`, `MYIP_SSL_FULLCHAIN`), so no `.env` changes are needed for local runs. Use `curl -sk` or `wget --no-check-certificate` to accept the self-signed cert (see [Usage](#usage)).

## Version Management

All pinned versions (Node.js, pnpm) live in one place — the top of [Makefile](Makefile). After editing those values, run `make sync` to propagate them to `.nvmrc` and `package.json`:

```bash
make sync
```

See [README_PNPM.md](README_PNPM.md) for pnpm usage, security configuration, and package management commands.

## Docker

```bash
make build      # Build the Docker image
make run        # Build and run in foreground
make start      # Build and start as daemon
make restart    # Build and restart as daemon
make stop       # Stop
make refresh    # Refresh the MaxMind database (if needed)
make test       # Build, start, and test the API
```

## Usage

```bash
header="Authorization: Bearer your_token"
# Note: --no-check-certificate is only needed for http; remove it when using HTTPS
wget -qO- --no-check-certificate --header="${header}" http://localhost:8888
curl -sk http://localhost:8888 -H "${header}"
# Outputs:
# {"ip":"your_ip","asn":"your_asn"}
# {"error":"Not found"}
```

## References

* https://dev.maxmind.com/geoip/updating-databases
* https://www.maxmind.com/en/accounts/current/geoip/downloads
