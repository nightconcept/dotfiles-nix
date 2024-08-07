#!/usr/bin/env bash

# only configured for Ubuntu

# resources:
# https://install.determinate.systems/
# https://nix-community.github.io/home-manager/

# install zsh and set as default shell
sudo apt-get install zsh -y
chsh -s /bin/zsh

# install nix
#curl --proto '=https' --tlsv1.2 -sSf -L \
#  https://install.determinate.systems/nix | sh -s -- install

# this might be better? this is working on wsl2 on w11 and ubuntu 22.04, the above command is not
# sh <(curl -L https://nixos.org/nix/install) --no-daemon

# install home manager standalone
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# get dotfiles
#git clone https://github.com/nightconcept/dotfiles-nix

# run home-manager to install
home-manager switch --flake .#ubuntu