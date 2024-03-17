# dotfiles-nix

My dotfiles for Nix, NixOS, and Nix-Darwin.

## Uses
- Desktop Environment (Linux): Plasma
- Shell: zsh
- Editor: nvim and vscode

More uses [here](https://www.solivan.dev/blog/uses/).

## Structure
- `/home` - User settings, configurations, and apps.
- `/hosts` - Host and OS specific software and hardware configuration

### Prerequisites?
- Zsh needs powerlevel10k installed via `nix-env` like so:
```sh
nix-env -i powerlevel10k
```

[Reference]([Using an external oh-my-zsh theme with zsh in nix? - Help - NixOS Discourse](https://discourse.nixos.org/t/using-an-external-oh-my-zsh-theme-with-zsh-in-nix/6142)