# dotfiles

My consolidated dotfiles for Linux-based OS, macOS, NixOS and Windows. Utilities related to system configuration setup and saving are also included.

## Uses

- Shell (*nix): zsh
- Terminal: wezterm
- Editor: vscode/nvim
- Font: Fira Code

More [uses](https://www.solivan.dev/blog/uses/).

## Structure
- `/home` - User programs, configuration, and desktop.
- `/hosts` - Host specific (Darwin and NixOS only) software and hardware configuration
- `/systems` - System (NixOS, Darwin, Windows) specific configuration.

## Homes (*nix)

- Darwin - Configuration for macOS Desktops
- Darwin-Laptop - Configuration for macOS Laptops
- Desktop - Configuration for Linux desktops
- NixOS Server - Configuration fo NixOS servers
- Server - Configuration for Linux servers

## Hosts

### Darwin Hosts

- Merlin - Mac Mini M1 HTPC (2020)
- Waver - MacBook Pro M1 (2020)

### NixOS Hosts

- Aerith - Plex configuration

## Usage

### Home Manager (Linux/macOS)

#### Setup

```shell
wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/nix-install.sh | bash
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

### NixOS

1. A fresh install of NixOS does not have git installed. It is best to add git (and particularly any other pre-requisites needed for the installation) to the configuration.nix file in /etc/nixos/configuration.nix and then run `nixos-rebuild switch`. Using `nix-shell -p git` may not always provide "enough" pre-requisites based off the configuration.

2. Run `nixos-rebuild switch --flake .#<CONFIG-NAME> --experimental-feature "nix-command flakes"` to switch over to the configuration in the flake.

## License

This software is [MIT licensed](LICENSE).
