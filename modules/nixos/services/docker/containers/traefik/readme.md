# Traefik
Container for traefik based off of original CasaOS's container.

## Config
A base traefik is included in the config folder. The contents of config are
intended to be mounted to `/etc/template`

Before running the container, make sure `pre-docker-config.sh` is run to properly add
proxy network.

## ⚠ Warnings ⚠
`acme.json` may need to have certificate cleared on new setup. Make sure this gets
cleared properly