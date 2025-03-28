#!/usr/bin/env bash

# Configured for Linux servers

# resources:
# https://install.determinate.systems/
# https://nix-community.github.io/home-manager/

# install curl
sudo apt-get install curl -y

# install nix
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# this might be better? this is working on wsl2 on w11 and ubuntu 22.04, the above command is not
# sh <(curl -L https://nixos.org/nix/install) --no-daemon

sudo echo "trusted-users = root danny" >> /etc/nix/nix.custom.conf

. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# install home manager standalone
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install