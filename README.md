# dotfiles-nix

My dotfiles for Nix, NixOS, and Nix-Darwin. NixOS has both a non-persisting and [persisting](https://grahamc.com/blog/erase-your-darlings/) configuration without encryption. I plan to add encryption next.

## Uses
- Desktop Environment (Linux): Hyprland
- Bar: waybar
- Shell: zsh
- Terminal: wezterm
- Editor: vscode

More uses [here](https://www.solivan.dev/blog/uses/).

## Structure
- `/home` - User programs, configuration, and desktop.
- `/hosts` - Host specific software and hardware configuration
- `/systems` - System (NixOS and Darwin) specific configuration.

## Dotfile credits/inspiration
- [hmajid2301/dotfiles](https://github.com/hmajid2301/dotfiles) - For hyprland config
- [HeinzDev/Hyprland-dotfiles](https://github.com/HeinzDev/Hyprland-dotfiles) - For hyprland config
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles) - For hyprland config