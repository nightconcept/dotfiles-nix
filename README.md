# dotfiles-nix

My dotfiles for Nix, NixOS, and Nix-Darwin. Nix-only configurations complement my automatic-os-setup repo.

## Uses
- Desktop Environment (Linux): Plasma 6
- Shell: zsh
- Terminal: wezterm
- Editor: vscode

More uses [here](https://www.solivan.dev/blog/uses/).

## Structure
- `/home` - User programs, configuration, and desktop.
- `/hosts` - Host specific software and hardware configuration
- `/systems` - System (NixOS and Darwin) specific configuration.

### Usage

#### NixOS

1. A fresh install of NixOS does not have git installed. It is best to add git (and particularly any other pre-requisites needed for the installation) to the configuration.nix file in /etc/nixos/configuration.nix and then run `nixos-rebuild switch`. Using `nix-shell -p git` may not always provide "enough" pre-requisites based off the configuration.

2. Run `nixos-rebuild switch --flake .#<CONFIG-NAME> --experimental-feature "nix-command flakes" to switch over to the configuration in the flake.

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