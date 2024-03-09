# dotfiles-nix

My dotfiles for Nix, NixOS, and Nix-Darwin.

## Uses
- Desktop Environment (Linux): Plasma
- Shell: zsh
- Editor: nvim and vscode

## Structure
flake - Main entry point

- machines/$OS/$MACHINENAME
    - OS specific configuration
        - Machine specific hardware configuration
- users/$USERNAME
    - User specific configuration, then calls /dots. Only one user at this time, but more could be added.