# dotfiles

Nix-based system configurations for NixOS, macOS, and Linux.

## Hosts

| Host | Type | Hardware | Purpose |
|------|------|----------|---------|
| `tidus` | NixOS | Dell Latitude 7420 | Primary laptop with Hyprland |
| `aerith` | NixOS | Server | Plex media server |
| `waver` | Darwin | MacBook Pro M1 | macOS laptop |
| `merlin` | Darwin | Mac Mini M1 | HTPC |

## Quick Start

```bash
# Universal bootstrap
wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
```

## Manual Usage

### NixOS
```bash
nixos-rebuild switch --flake .#tidus
nixos-rebuild switch --flake .#aerith
```

### Darwin
```bash
darwin-rebuild switch --flake .#waver
darwin-rebuild switch --flake .#merlin
```

### Home Manager (standalone)
```bash
home-manager switch --flake .#desktop
home-manager switch --flake .#laptop
home-manager switch --flake .#server
```

## Structure

- `/flake.nix` - Main flake configuration
- `/lib/` - Helper functions for system builders
- `/home/` - User configurations and programs
  - `/profiles/` - Composable configuration profiles
  - `/programs/` - Application configs
  - `/desktops/` - Desktop environments
- `/hosts/` - Machine-specific configurations
- `/systems/` - Platform configurations (NixOS/Darwin)

## Stack

- **Shell**: fish/zsh
- **Terminal**: wezterm + zellij
- **Editor**: neovim/vscode
- **Desktop**: Hyprland (NixOS)
- **Theme**: Tokyo Night
- **Font**: Inter Nerd Font

## License

[MIT](LICENSE)