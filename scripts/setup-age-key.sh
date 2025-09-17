#!/usr/bin/env bash

# setup-age-key.sh - Convert SSH key to age key for sops-nix
# This script runs the conversion in a nix shell with ssh-to-age available

set -euo pipefail

# Run the actual conversion script with nix-shell
nix-shell -p ssh-to-age --run bash << 'EOF'
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SSH_KEY_PATH="$HOME/.ssh/id_sdev"
AGE_KEY_DIR="$HOME/.config/sops/age"
AGE_KEY_PATH="$AGE_KEY_DIR/keys.txt"
SOPS_CONFIG=".sops.yaml"

# Function to print colored messages
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if running from the dotfiles-nix directory
if [[ ! -f "$SOPS_CONFIG" ]]; then
    print_error "This script must be run from the dotfiles-nix directory"
    print_info "Please cd to your dotfiles-nix directory and run again"
    exit 1
fi

print_info "Setting up age key from SSH key for sops-nix..."

# Check if SSH key exists
if [[ ! -f "$SSH_KEY_PATH" ]]; then
    print_error "SSH key not found at $SSH_KEY_PATH"
    print_info "Please ensure you have the id_sdev SSH key in your .ssh directory"
    exit 1
fi

# Create age key directory if it doesn't exist
if [[ ! -d "$AGE_KEY_DIR" ]]; then
    print_info "Creating age key directory at $AGE_KEY_DIR"
    mkdir -p "$AGE_KEY_DIR"
fi

# Check if age key already exists
if [[ -f "$AGE_KEY_PATH" ]]; then
    print_warning "Age key already exists at $AGE_KEY_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing age key"
        exit 0
    fi
fi

# Convert SSH key to age key
print_info "Converting SSH key to age key..."
if ssh-to-age -private-key -i "$SSH_KEY_PATH" > "$AGE_KEY_PATH" 2>/dev/null; then
    print_success "Age key successfully created at $AGE_KEY_PATH"
    
    # Set proper permissions
    chmod 600 "$AGE_KEY_PATH"
    print_info "Set permissions to 600 for age key"
else
    print_error "Failed to convert SSH key to age key"
    print_info "Please check that your SSH key is valid"
    exit 1
fi

# Get the age public key for display
AGE_PUBLIC_KEY=$(ssh-to-age < "$SSH_KEY_PATH.pub" 2>/dev/null || echo "Could not derive public key")

print_success "Age key setup complete!"
echo
print_info "Age public key (for .sops.yaml):"
echo "  $AGE_PUBLIC_KEY"
echo
print_info "Next steps:"
echo "  1. Ensure the age public key above matches what's in your .sops.yaml file"
echo "  2. Rebuild your NixOS/home-manager configuration:"
echo "     - For NixOS: sudo nixos-rebuild switch --flake .#<hostname>"
echo "     - For home-manager: home-manager switch --flake .#<config>"
echo
print_info "The age key will be used automatically by sops-nix to decrypt secrets"
EOF