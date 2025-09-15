# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Nix flake configuration for personal dotfiles supporting multiple platforms:
- **NixOS**: Full system configurations for Linux desktops and servers
- **nix-darwin**: macOS system configurations  
- **home-manager**: User-level configurations for any system

## Common Commands

### NixOS System Rebuild
```bash
# Switch to a NixOS configuration
nixos-rebuild switch --flake .#<CONFIG-NAME> --experimental-feature "nix-command flakes"

# Example configurations:
nixos-rebuild switch --flake .#tidus
nixos-rebuild switch --flake .#aerith
```

### Darwin System Rebuild
```bash
# Switch to a Darwin configuration
darwin-rebuild switch --flake .#<CONFIG-NAME>

# Example configurations:
darwin-rebuild switch --flake .#waver
darwin-rebuild switch --flake .#merlin
```

### Home Manager
```bash
# Linux configurations
home-manager switch --flake '.#cli'
home-manager switch --flake '.#desktop'

# macOS configurations (use hostname)
home-manager switch --flake '.#waver'
home-manager switch --flake '.#merlin'
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
- `/flake.nix` - Main flake configuration defining all system outputs
- `/home/` - Home Manager user configurations and program settings
- `/hosts/` - Host-specific configurations (hardware, networking, services)
- `/systems/` - Platform-specific system configurations (NixOS/Darwin)

### Configuration Hierarchy

#### NixOS Systems
1. `flake.nix` defines `mkNixos` or `mkNixosServer` functions
2. Imports `./systems/nixos` (base system config)
3. Imports `./hosts/nixos/<hostname>` (host-specific config)  
4. Includes Home Manager with `./home` user configs

#### Darwin Systems
1. `flake.nix` defines `mkDarwin` function
2. Imports `./systems/darwin` (base macOS config)
3. Imports `./hosts/darwin/<hostname>` (host-specific config)
4. Includes Home Manager with `./home/home-darwin.nix`

#### Home Manager Standalone
1. `flake.nix` defines `homeConfigurations`
2. Uses specific home configs: `home-cli.nix`, `home-desktop.nix`, etc.

### Key Components

- **Systems**: Base platform configurations in `/systems/{nixos,darwin}/`
- **Hosts**: Individual machine configs in `/hosts/{nixos,darwin}/<hostname>/`
- **Programs**: User application configs in `/home/programs/`
- **Hardware**: Hardware-specific settings in `/systems/nixos/hardware/`

### Host Configurations

#### Active NixOS Hosts
- `aerith` - Plex media server (uses `mkNixosServer`)
- `tidus` - Dell NixOS Laptop

#### Active Darwin Hosts  
- `waver` - MacBook Pro
- `merlin` - Mac Mini HTPC

## Development Workflow

1. Make changes to relevant configuration files
2. Test changes locally with rebuild commands
3. Commit changes to git
4. The flake.lock should be updated periodically with `nix flake update`

## Bootstrap Process

New Linux systems can be bootstrapped using:
```bash
wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
```

This installs Nix and Home Manager on non-NixOS systems.