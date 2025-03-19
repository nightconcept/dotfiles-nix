# dotfiles-nix

My dotfiles for Nix, NixOS, and Nix-Darwin. Nix-only configurations complement my automatic-os-setup repo.

## Uses (NixOS)
- Desktop Environment (Linux): Plasma 6
- Shell: zsh
- Terminal: wezterm
- Editor: vscode

More uses [here](https://www.solivan.dev/blog/uses/).

## Structure
- `/home` - User programs, configuration, and desktop.
- `/hosts` - Host specific software and hardware configuration
- `/systems` - System (NixOS and Darwin) specific configuration.

## Homes
- Darwin - Configuration for macOS
- Desktop - Configuration for Linux desktops (non-NixOS)
- NixOS Server - Configuration fo NixOS servers
- Server - Configuration for non-NixOS Linux servers
- WSL - Configuration for WSL

## Hosts
### NixOS Hosts
- Aerith - Dedicated Plex configuration
- Celes - **(Deprecated)** configuration for main PC
- Cloud - **(Deprecated)** configuration for laptop
- Phoenix - **Spare** configuration for a VM

### Darwin Hosts
- Merlin - Mac Mini HTPC
- Waver - MacBook Pro

## Usage

### NixOS

1. A fresh install of NixOS does not have git installed. It is best to add git (and particularly any other pre-requisites needed for the installation) to the configuration.nix file in /etc/nixos/configuration.nix and then run `nixos-rebuild switch`. Using `nix-shell -p git` may not always provide "enough" pre-requisites based off the configuration.

2. Run `nixos-rebuild switch --flake .#<CONFIG-NAME> --experimental-feature "nix-command flakes"` to switch over to the configuration in the flake.

### Nix Home Manager (macOS/Linux)

Run the following commands to get Nix, Home Manager, and 

```shell
// Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

// Install Home Manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

// Clone
git clone https://github.com/nightconcept/dotfiles-nix
cd dotfiles-nix

// Variations of home manager switch for Linux
home-manager switch --flake '.#desktop'
home-manager switch --flake '.#server'
home-manager switch --flake '.#wsl'

// Variations of home manager switch for macOS
home-manager switch --flake '.#merlin'
home-manager switch --flake '.#waver'
```

## Dotfile credits/inspiration
- [hmajid2301/dotfiles](https://github.com/hmajid2301/dotfiles)
- [HeinzDev/Hyprland-dotfiles](https://github.com/HeinzDev/Hyprland-dotfiles)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [nzbr/nixos](https://github.com/nzbr/nixos)
- [notusknot/dotfiles-nix](https://github.com/notusknot/dotfiles-nix)
- [NobbZ/nixos-config](https://github.com/NobbZ/nixos-config)
- [notthebee/nix-config](https://github.com/notthebee/nix-config)
- [ericmurphyxyz/dotfiles](https://github.com/ericmurphyxyz/dotfiles)
- [sane1090x/dotfiles](https://github.com/sane1090x/dotfiles)
- [gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles)
- [Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config/tree/main)
- [BirdeeHub/birdeeSystems)](https://github.com/BirdeeHub/birdeeSystems)
- [LongerHV/nixos-configuration](https://github.com/LongerHV/nixos-configuration)
- [badele/nix-homelab](https://github.com/badele/nix-homelab/tree/main?tab=readme-ov-file)
- [SomeGuyNamedMay/users](https://github.com/SomeGuyNamedMay/users)