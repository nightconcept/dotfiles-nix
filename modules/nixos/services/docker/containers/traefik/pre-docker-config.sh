#!/usr/bin/env bash
# create proxy network in docker first
docker network create proxy
sudo chmod 600 ./config/acme.json