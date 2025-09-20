#!/usr/bin/env bash
# Build script for tidus-persist installer ISO

set -e

echo "======================================="
echo "Building Tidus-Persist NixOS Installer ISO"
echo "======================================="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    echo -e "${RED}Error: flake.nix not found!${NC}"
    echo "Please run this script from the dotfiles-nix root directory"
    exit 1
fi

# Parse arguments
QUICK_BUILD=false
if [ "$1" = "--quick" ]; then
    QUICK_BUILD=true
    echo -e "${YELLOW}Quick build mode: Skipping checks${NC}"
fi

# Run flake check unless --quick
if [ "$QUICK_BUILD" = false ]; then
    echo "Running flake check..."
    if nix flake check --no-build 2>/dev/null; then
        echo -e "${GREEN}✓ Flake check passed${NC}"
    else
        echo -e "${YELLOW}⚠ Flake check had warnings (continuing anyway)${NC}"
    fi
    echo
fi

# Build the ISO
echo "Building ISO image..."
echo "This may take 10-20 minutes on first build..."
echo

if nix build .#nixosConfigurations.tidus-persist-installer.config.system.build.isoImage; then
    echo
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo

    # Find the ISO
    ISO_PATH=$(find result/iso -name "*.iso" 2>/dev/null | head -1)

    if [ -n "$ISO_PATH" ]; then
        ISO_SIZE=$(du -h "$ISO_PATH" | cut -f1)
        echo "ISO created: $ISO_PATH"
        echo "Size: $ISO_SIZE"
        echo
        echo "To write to USB drive:"
        echo "  sudo dd if=$ISO_PATH of=/dev/sdX bs=4M status=progress"
        echo
        echo "Or copy to a permanent location:"
        echo "  cp $ISO_PATH ~/tidus-persist-installer-$(date +%Y%m%d).iso"
    else
        echo -e "${YELLOW}Warning: ISO built but not found in expected location${NC}"
        echo "Check ./result/ directory"
    fi
else
    echo
    echo -e "${RED}✗ Build failed!${NC}"
    echo "Try running with --show-trace for more details:"
    echo "  nix build .#nixosConfigurations.tidus-persist-installer.config.system.build.isoImage --show-trace"
    exit 1
fi