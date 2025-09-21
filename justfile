# Just commands for dotfiles-nix

# Check all flake configurations
check:
    NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure

# Check home-manager configurations only
check-home:
    NIXPKGS_ALLOW_UNFREE=1 nix build .#homeConfigurations.desktop.activationPackage --dry-run --impure
    NIXPKGS_ALLOW_UNFREE=1 nix build .#homeConfigurations.laptop.activationPackage --dry-run --impure  
    NIXPKGS_ALLOW_UNFREE=1 nix build .#homeConfigurations.server.activationPackage --dry-run --impure

# Check NixOS configurations only (may fail due to lix issues)
check-nixos:
    NIXPKGS_ALLOW_UNFREE=1 nix build .#nixosConfigurations.tidus.config.system.build.toplevel --dry-run --impure
    NIXPKGS_ALLOW_UNFREE=1 nix build .#nixosConfigurations.aerith.config.system.build.toplevel --dry-run --impure
    NIXPKGS_ALLOW_UNFREE=1 nix build .#nixosConfigurations.barrett.config.system.build.toplevel --dry-run --impure

# Check Darwin configurations only (may fail due to stylix issues)  
check-darwin:
    NIXPKGS_ALLOW_UNFREE=1 nix build .#darwinConfigurations.waver.system --dry-run --impure
    NIXPKGS_ALLOW_UNFREE=1 nix build .#darwinConfigurations.merlin.system --dry-run --impure

# Update flake inputs
update:
    nix flake update

# Show flake outputs
show:
    nix flake show

# Build a specific NixOS configuration without switching
build-nixos config:
    nixos-rebuild build --flake .#{{config}}

# Build a specific Darwin configuration without switching  
build-darwin config:
    darwin-rebuild build --flake .#{{config}}

# Build a specific Home Manager configuration without switching
build-home config:
    home-manager build --flake .#{{config}}

# Switch to a NixOS configuration
switch-nixos config:
    sudo nixos-rebuild switch --flake .#{{config}}

# Switch to a Darwin configuration
switch-darwin config:
    sudo darwin-rebuild switch --flake .#{{config}}

# Switch to a Home Manager configuration
switch-home config:
    home-manager switch --flake .#{{config}}

# Clean up build artifacts
clean:
    sudo nix-collect-garbage -d

# Format all Nix files
fmt:
    nix fmt

# Pin a NixOS host to current flake nixpkgs version using npins
pin-host host:
    #!/usr/bin/env bash
    set -euo pipefail
    HOST_DIR="hosts/nixos/{{host}}"
    if [ ! -d "$HOST_DIR" ]; then
        echo "Error: Host directory $HOST_DIR does not exist"
        exit 1
    fi
    cd "$HOST_DIR"

    # Check if npins already exists
    if [ -d "npins" ]; then
        echo "npins already initialized for {{host}}, updating to current flake commit..."
        COMMIT=$(cd ../../.. && nix flake metadata --json | jq -r '.locks.nodes.nixpkgs.locked.rev')
        nix-shell -p npins jq --run "npins update nixpkgs --at $COMMIT"
    else
        echo "Initializing npins for {{host}}..."
        nix-shell -p npins --run "npins init --bare"
        COMMIT=$(cd ../../.. && nix flake metadata --json | jq -r '.locks.nodes.nixpkgs.locked.rev')
        echo "Pinning to nixpkgs commit: $COMMIT"
        nix-shell -p npins jq --run "npins add github nixos nixpkgs --branch nixos-unstable --at $COMMIT"
        echo "npins initialized. You need to update $HOST_DIR/default.nix to use pinned packages."
        echo "Add this to your host configuration:"
        echo ""
        echo "let"
        echo "  sources = import ./npins;"
        echo "  pinnedPkgs = import sources.nixpkgs {"
        echo "    system = pkgs.system;"
        echo "    config = config.nixpkgs.config;"
        echo "  };"
        echo "in {"
        echo "  # ... your config"
        echo "  nixpkgs.pkgs = pinnedPkgs;"
        echo "}"
    fi

# Update npins for a specific host
update-pin host:
    #!/usr/bin/env bash
    set -euo pipefail
    HOST_DIR="hosts/nixos/{{host}}"
    if [ ! -d "$HOST_DIR/npins" ]; then
        echo "Error: npins not initialized for {{host}}"
        echo "Run 'just pin-host {{host}}' first"
        exit 1
    fi
    cd "$HOST_DIR"
    nix-shell -p npins --run "npins update nixpkgs"
    echo "Updated {{host}} to latest nixpkgs-unstable"

# Show pinned version for a host
show-pin host:
    #!/usr/bin/env bash
    set -euo pipefail
    HOST_DIR="hosts/nixos/{{host}}"
    if [ ! -d "$HOST_DIR/npins" ]; then
        echo "Error: npins not initialized for {{host}}"
        exit 1
    fi
    cd "$HOST_DIR"
    echo "{{host}} is pinned to:"
    nix-shell -p npins --run "npins show" | grep -A2 nixpkgs

# List all hosts with npins
list-pinned:
    #!/usr/bin/env bash
    echo "Hosts with npins version management:"
    for dir in hosts/nixos/*/npins; do
        if [ -d "$dir" ]; then
            host=$(basename $(dirname "$dir"))
            revision=$(cd "$dir/.." && nix-instantiate --eval -E '(import ./npins).nixpkgs.revision' 2>/dev/null | tr -d '"')
            echo "  - $host: ${revision:0:8}"
        fi
    done