# Desired Module-Based Architecture

## Core Structure

```
dotfiles-nix/
├── modules/          # All reusable modules
│   ├── nixos/        # NixOS system modules
│   ├── darwin/       # Darwin system modules
│   ├── home/         # Home-manager modules
│   └── shared/       # Cross-platform modules
├── hosts/            # Individual machine configurations
│   ├── nixos/
│   │   ├── tidus/    # Just declares what modules to enable
│   │   └── aerith/
│   └── darwin/
│       ├── waver/
│       └── merlin/
├── home/             # Profile-based configurations
│   ├── profiles/     # Composable profiles (base, desktop, laptop, server)
│   └── default.nix   # Profile selector for standalone home-manager
└── lib/              # Helper functions
    ├── lib.nix       # Simplified mkSystem/mkDarwin functions
    └── module/       # Module helpers (mkOpt, mkBoolOpt, enabled, disabled)
```

## Key Principles

1. **Modules are self-contained features** - Each module defines its own options using helper functions
2. **Hosts become declarative** - Just enable/disable modules, no complex imports
3. **Smart dependencies** - Modules can enable other modules (e.g., laptop.enable → desktop.enable)
4. **Platform-aware** - Modules use mkIf conditions to handle platform differences
5. **Single source of truth** - Each feature lives in ONE module directory

## Example Host Configuration

```nix
# hosts/nixos/aerith/default.nix
{
  networking.hostName = "aerith";

  modules = {
    server.enable = true;         # Auto-configures SSH, no GUI, etc.
    services.plex.enable = true;  # Just turn on features
    kernel.type = "lts";
  };
}
```

## Module Organization Pattern

- Applications that span system/user boundaries use coordinating modules
- Example: VSCode would have `modules/nixos/programs/vscode/`, `modules/darwin/programs/vscode/`, and `modules/home/programs/vscode/`
- Single enable flag can activate across all layers

## End Goal

- Remove `systems/` folder entirely (contents → modules)
- Simplify `lib.nix` to just `mkSystem` and `mkDarwin` (no special server/laptop variants)
- Hosts become simple manifests declaring what they want
- Home-manager integration is standard for all NixOS/Darwin configs

## Current Progress

- Created `lib/module/` with helper functions
- Started with `modules/nixos/` containing kernel, network, and Plex service modules
- Successfully refactored aerith host to use new module system
- Removed unnecessary `services.xserver.enable` from headless server