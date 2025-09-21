#!/usr/bin/env bash

echo "Testing SOPS configuration..."
echo ""

# Check age key
echo "=== System age key ==="
if [[ -f /var/lib/sops-nix/key.txt ]]; then
    echo "✓ Age key exists at /var/lib/sops-nix/key.txt"
    sudo head -c 20 /var/lib/sops-nix/key.txt && echo "..."
else
    echo "✗ Age key not found at /var/lib/sops-nix/key.txt"
fi
echo ""

# Check SSH host keys
echo "=== SSH host keys ==="
ls -la /etc/ssh/ssh_host_ed25519_key* 2>/dev/null || echo "No ED25519 host key"
echo ""

# Check secrets deployment locations
echo "=== Secret deployment locations ==="
echo "Checking /run/secrets:"
ls -la /run/secrets 2>/dev/null || echo "Directory not found"
echo ""

echo "Checking /run/secrets.d:"
sudo ls -la /run/secrets.d 2>/dev/null || echo "Directory not found"
echo ""

# Try to find where secrets are actually deployed
echo "=== Finding secret files ==="
sudo find /run -name "*nordvpn*" -o -name "*titan*" 2>/dev/null | head -10
echo ""

# Check SOPS service status
echo "=== SOPS activation status ==="
sudo journalctl -b | grep -i sops-install-secrets | tail -10
echo ""

echo "=== Manual SOPS test ==="
echo "Trying to decrypt secrets manually..."
if command -v sops &>/dev/null; then
    cd /home/danny/git/dotfiles-nix
    # Try to view the secrets (will only work if age key is correct)
    echo "Attempting to decrypt common.yaml:"
    sops -d modules/nixos/security/sops/common.yaml 2>&1 | grep -E "(nordvpn_token|titan_credentials)" | head -5
else
    echo "sops command not found"
fi