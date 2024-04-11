#!/usr/bin/env bash

# assumed you decrypted already

# partial reference: https://github.com/vimjoyer/impermanent-setup

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /home/nixos/dotfiles-nix/hosts/nixos/cloud/disks.nix

sudo nixos-install --root /mnt --flake /home/nixos/dotfiles-nix/#cloud