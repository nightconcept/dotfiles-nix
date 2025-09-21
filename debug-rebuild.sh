#!/usr/bin/env bash

echo "Debug rebuild with verbose SOPS output..."
echo ""

# First, verify the age key works
echo "=== Testing age key decryption ==="
cd /home/danny/git/dotfiles-nix

# Install sops if needed
if ! command -v sops &>/dev/null; then
    echo "Installing sops..."
    nix-env -iA nixpkgs.sops
fi

# Try to decrypt with user key
export SOPS_AGE_KEY_FILE=/home/danny/.config/sops/age/keys.txt
echo "Testing decryption with user age key:"
sops -d modules/nixos/security/sops/common.yaml 2>&1 | grep -E "nordvpn_token|titan_credentials" | head -2

# Try with system key
echo ""
echo "Testing decryption with system age key:"
sudo sh -c 'export SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt && sops -d /home/danny/git/dotfiles-nix/modules/nixos/security/sops/common.yaml' 2>&1 | grep -E "nordvpn_token|titan_credentials" | head -2

echo ""
echo "=== Rebuilding with debug output ==="
sudo nixos-rebuild switch --flake .#barrett --show-trace 2>&1 | tee rebuild.log | grep -E "(sops|secret|nordvpn|titan)"

echo ""
echo "=== Checking results ==="
echo "Secrets directory:"
sudo ls -la /run/secrets.d/1/ 2>/dev/null || echo "Not found"

echo ""
echo "Service status:"
systemctl status wgnord --no-pager | head -5