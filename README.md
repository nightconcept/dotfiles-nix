# dotfiles-nix

My dotfiles for Nix, NixOS, and Nix-Darwin. Nix-only configurations complement my automatic-os-setup repo.

## Uses

- Shell: zsh
- Terminal: wezterm
- Editor: vscode/nvim
- Font: Fira Code

More [uses](https://www.solivan.dev/blog/uses/).

## Structure
- `/home` - User programs, configuration, and desktop.
- `/hosts` - Host specific software and hardware configuration
- `/systems` - System (NixOS and Darwin) specific configuration.

## Homes

- Darwin - Configuration for macOS Desktops
- Darwin-Laptop - Configuration for macOS Laptops
- Desktop - Configuration for Linux desktops
- NixOS Server - Configuration fo NixOS servers
- Server - Configuration for Linux servers

## Hosts

### NixOS Hosts

- Aerith - Plex/Jellyfin configuration

### Darwin Hosts

- Merlin - Mac Mini M1 HTPC (2020)
- Waver - MacBook Pro M1 (2020)

## Usage

### NixOS

1. A fresh install of NixOS does not have git installed. It is best to add git (and particularly any other pre-requisites needed for the installation) to the configuration.nix file in /etc/nixos/configuration.nix and then run `nixos-rebuild switch`. Using `nix-shell -p git` may not always provide "enough" pre-requisites based off the configuration.

2. Run `nixos-rebuild switch --flake .#<CONFIG-NAME> --experimental-feature "nix-command flakes"` to switch over to the configuration in the flake.

### Home Manager

#### Setup

```shell
wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
```

#### Home Manager Switch Commands

```shell
// Variations of home manager switch for Linux, pick only one
home-manager switch --flake '.#desktop'
home-manager switch --flake '.#server'

// Variations of home manager switch for macOS, pick only one
darwin-rebuild switch --flake '.#merlin'
darwin-rebuild switch --flake '.#waver'
```

## License

This software is [MIT licensed](LICENSE).
