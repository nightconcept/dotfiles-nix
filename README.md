# snowdots

NixOS, macOS, and Linux system configurations managed by [Nix](https://nixos.org/) and (soon) Windows system configurations managed by Yuki (WIP).

## Uses

- **Shell**: fish
- **Terminal**: wezterm
- **Editor**: neovim/vscode
- **Desktop**: Hyprland (NixOS)
- **Theme**: Tokyo Night
- **Font**: Inter Nerd Font/Fira Code Nerd Font


## Configuration Paths
- NixOS Laptop - Hyprland DE
- NixOS Server - Headless Plex Server
- Darwin Laptop - Aerospace DE with common macOS applications
- Darwin Desktop - Regular macOS with common macOS applications
- Linux Desktop - Desktop + CLI Linux Applications
- Linux Server - CLI Linux Applications

## Hosts

| Host | Type | Hardware | Purpose |
|------|------|----------|---------|
| `tidus` | NixOS | Dell Latitude 7420 | Linux Laptop with Hyprland DE |
| `aerith` | NixOS | VM | Plex media server |
| `waver` | Darwin | MacBook Pro M1 | macOS Laptop with Aerospace DE |
| `merlin` | Darwin | Mac Mini M1 | macOS Desktop HTPC |

## Homes

| Home | Type | Hardware | Purpose |
|------|------|----------|---------|
| `desktop` | Linux | Any | Linux Computer with common desktop and CLI tools |
| `server` | Linux | Any | Linux Server with common CLI tools |

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

## License

[MIT](LICENSE)
