# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ ARCHITECTURAL MIGRATION IN PROGRESS

**IMPORTANT**: This codebase is actively migrating from a systems-based to a module-based architecture. See `/docs/architecture.md` for the desired end state. You will encounter both patterns during the transition.

### Migration Guidelines
- **NEW CODE**: Always use the module-based pattern (`modules.nixos.*`)
- **EXISTING CODE**: Migrate to modules when making significant changes  
- **HOSTS**: New hosts should follow the barrett/aerith pattern (module-based)

## Project Overview

This is a Nix flake configuration for personal dotfiles supporting multiple platforms:
- **NixOS**: Full system configurations for Linux desktops and servers
- **nix-darwin**: macOS system configurations  
- **home-manager**: User-level configurations for any system

## Common Commands

### NixOS System Rebuild
```bash
# Switch to a NixOS configuration
nixos-rebuild switch --flake .#<CONFIG-NAME>

# Example configurations:
nixos-rebuild switch --flake .#tidus
nixos-rebuild switch --flake .#aerith
nixos-rebuild switch --flake .#barrett
```

### Darwin System Rebuild
```bash
# Switch to a Darwin configuration
sudo darwin-rebuild switch --flake .#<CONFIG-NAME>

# Example configurations:
sudo darwin-rebuild switch --flake .#waver
sudo darwin-rebuild switch --flake .#merlin
```

### Home Manager
```bash
# Standalone configurations
home-manager switch --flake '.#desktop'
home-manager switch --flake '.#laptop'
home-manager switch --flake '.#server'
```

### Flake Operations
```bash
# Update flake inputs
nix flake update

# Check flake configuration
nix flake check

# Show flake outputs
nix flake show
```

## Architecture

### Directory Structure
**NOTE**: The codebase contains both OLD STYLE (systems-based) and NEW STYLE (module-based) patterns during migration.

- `/flake.nix` - Main flake configuration defining all system outputs
- `/lib/lib.nix` - Helper functions (mkNixos, mkDarwin, mkHome, etc.)
- `/home/` - Home Manager user configurations
  - `default.nix` - Profile selector based on hostname
  - `profiles/` - Composable configuration profiles
    - `base.nix` - Common to all systems
    - `desktop.nix` - GUI applications
    - `laptop.nix` - Laptop-specific (extends desktop)
    - `server.nix` - Minimal server config
    - `darwin.nix` - macOS-specific
  - `programs/` - Application configurations
  - `desktops/` - Desktop environment configs
  - `secrets/` - User-level sops secrets
- `/hosts/` - Host-specific configurations (hardware, networking, services)
- `/systems/` - Platform-specific system configurations
  - `nixos/` - NixOS system configuration
    - `pkgs/` - Custom packages and system packages
    - `secrets/` - System-level sops secrets
    - `hardware/` - Hardware configurations
    - `desktops/` - Desktop environment modules (Hyprland, Plasma6)
  - `darwin/` - macOS system configuration

### Configuration Hierarchy

#### NixOS Systems
1. `flake.nix` calls `lib.mkNixos` or `lib.mkNixosServer`
2. Imports `./systems/nixos` (base system config)
3. Imports `./hosts/nixos/<hostname>` (host-specific config)
4. Includes Home Manager with `./home` (uses default.nix selector)

#### Darwin Systems
1. `flake.nix` calls `lib.mkDarwin` or `lib.mkDarwinLaptop`
2. Imports `./systems/darwin` (base macOS config)
3. Imports `./hosts/darwin/<hostname>` (host-specific config)
4. Includes Home Manager with `./home` (uses default.nix selector)

#### Home Manager Standalone
1. `flake.nix` calls `lib.mkHome`
2. Imports `./home` with hostname parameter
3. `default.nix` selects appropriate profiles

### Profile System

The home configuration uses a profile-based system where `home/default.nix` selects the appropriate profiles based on hostname:

- **tidus**: `base + laptop` (NixOS laptop)
- **aerith**: `base + server` (NixOS server)
- **barrett**: `base + server` (NixOS server)
- **waver**: `base + darwin-laptop` (MacBook)
- **merlin**: `base + darwin` (Mac Mini)
- **desktop/laptop/server**: Generic standalone profiles

### Key Components
- **Modules**: NEW STYLE self-contained feature modules in `/modules/{nixos,darwin,home,shared}/`

- **Systems**: Base platform configurations in `/systems/{nixos,darwin}/`
- **Hosts**: Individual machine configs in `/hosts/{nixos,darwin}/<hostname>/`
- **Programs**: User application configs in `/home/programs/`
- **Hardware**: Hardware-specific settings in `/systems/nixos/hardware/`
- **Desktops**: Desktop environment configs in `/home/desktops/`
- **Themes**: Stylix theming configuration in `/home/stylix.nix`
- **Wallpapers**: Wallpaper images in `/wallpaper/`
- **Secrets**: SOPS-managed secrets in `*/secrets/`

### Host Configurations

#### Active NixOS Hosts
- `aerith` - Plex media server (NEW STYLE - module-based)
- `barrett` - VPN torrent server (NEW STYLE - module-based)
- `tidus` - Dell Latitude 7420 laptop with Hyprland (OLD STYLE - to be migrated)

#### Active Darwin Hosts  
- `waver` - MacBook Pro M1
- `merlin` - Mac Mini M1 HTPC

## Development Workflow

1. Make changes to relevant configuration files
2. Test changes locally with rebuild commands
3. Commit changes to git
4. The flake.lock should be updated periodically with `nix flake update`

## Hyprland Desktop Environment

The Hyprland configuration is modular and includes:

### Core Components (`/home/desktops/hyprland/`)
- `hyprland.nix` - Main Hyprland window manager configuration
- `waybar.nix` - Status bar configuration with Tokyo Night theme
- `hypridle.nix` - Idle management with power-aware timeouts
- `hyprlock.nix` - Lock screen with Mac-style interface
- `wlogout.nix` - Power menu with Stylix colors
- `wofi.nix` - Application launcher with Tokyo Night theme
- `mako.nix` - Notification daemon
- `gtk-settings.nix` - GTK theming

### Theming
- Uses Stylix with Tokyo Night color scheme
- Consistent theming across all applications
- Custom wallpaper support in `/wallpaper/`

### Key Bindings
- `Super+Return/T` - Open terminal (WezTerm)
- `Super+Space` - Application launcher (wofi)
- `Super+L` - Lock screen (hyprlock)
- `Super+Backspace` - Power menu (wlogout)
- `Alt+Tab` - Cycle windows
- `F1-F4` - Audio controls
- `F6-F7` - Brightness controls
- Print screen variations for screenshots

## Bootstrap Process

New systems can be bootstrapped using:
```bash
wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
```

The bootstrap script:
- Detects OS (NixOS, Linux, macOS)
- Installs Nix if needed
- Clones this repository
- On NixOS: Offers host selection (tidus/aerith)
- On Linux: Sets up Home Manager with profile selection
- On macOS: Provides manual instructions

## SOPS Secret Management

Secrets are managed using sops-nix:
- User secrets in `/home/secrets/`
- System secrets in `/systems/nixos/secrets/`
- Age keys derived from SSH keys
- Automatic deployment to runtime directories
### Secret Storage Conventions

#### Deployed Secret Paths
System services (NixOS) should use:
- `/run/secrets/<service>-<secret>` - Standard SOPS deployment path
- Example: `/run/secrets/nordvpn-token`

User services (home-manager) should use:
- `$XDG_RUNTIME_DIR/secrets/<secret>` - User runtime directory (tmpfs)
- Expands to `/run/user/1000/secrets/<secret>`
- Example: `/run/user/1000/secrets/gemini_api_key`

#### Current Configured Secrets
System-level (`/systems/nixos/secrets/sops.nix`):
- `ssh_keys/id_sdev` → `/home/danny/.ssh/id_sdev`
- `network/titan_credentials` → `/etc/sops-mog-secrets`
- `vpn/nordvpn_token` → `/run/secrets/nordvpn-token`

User-level (`/home/secrets/sops.nix`):
- `id_sdev` → `~/.ssh/id_sdev`
- `gemini_api_key` → `$XDG_RUNTIME_DIR/secrets/gemini_api_key`

#### Adding New Secrets
1. Edit the YAML file (`common.yaml` or `user.yaml`)
2. Add the secret definition in the appropriate `sops.nix`
3. Follow the path conventions above for consistency
