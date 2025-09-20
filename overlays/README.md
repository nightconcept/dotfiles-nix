# Nixpkgs Overlays

This directory contains reusable overlays for the NixOS/nix-darwin configurations.

## Available Overlays

### unstable-packages.nix
Exposes the entire unstable package set under `pkgs.unstable.*` namespace.
This allows selective use of unstable packages on stable systems.

**Usage example:**
```nix
{ inputs, ... }:
{
  nixpkgs.overlays = [
    (import ../../../overlays/unstable-packages.nix { inherit inputs; })
  ];

  environment.systemPackages = with pkgs; [
    vim  # From stable
    unstable.neovim  # From unstable
  ];
}
```

### use-unstable.nix
Replaces specific packages with their unstable versions at the top level.
Edit this file to add packages that should always use unstable.

**Note:** Some services like Plex have built-in options for using unstable versions.
Check the module options before adding packages here.

**Usage example:**
```nix
{ inputs, ... }:
{
  nixpkgs.overlays = [
    (import ../../../overlays/use-unstable.nix { inherit inputs; })
  ];
}
```

## Adding New Overlays

1. Create a new `.nix` file in this directory
2. Follow the pattern: accept `{ inputs }` and return a function `final: prev: { ... }`
3. Import it in your host configuration with the appropriate inputs

## Current Usage

- **aerith** (server): Uses `modules.nixos.services.plex.useUnstable = true` option
- **barrett** (server): Can use these overlays if needed
- **tidus** (laptop): Runs fully on unstable, doesn't need these overlays

## Module-Based Unstable Options

Some modules provide built-in options for using unstable packages:

### Plex Module
```nix
modules.nixos.services.plex = {
  enable = true;
  useUnstable = true;  # Uses unstable plex on stable system
};
```