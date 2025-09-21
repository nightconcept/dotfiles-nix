#!/usr/bin/env bash

echo "Checking SOPS deployment..."
echo ""

# Check if secrets are actually deployed anywhere
echo "=== Finding deployed secrets ==="
sudo find /run -type f -name "*" 2>/dev/null | grep -E "(secret|sops)" | head -20

echo ""
echo "=== Check systemd status for sops ==="
systemctl list-units | grep -i sops

echo ""
echo "=== Check activation logs ==="
sudo journalctl -b --no-pager | grep -E "(sops|secret)" | grep -v "pam_unix" | tail -15

echo ""
echo "=== Check if secrets.d exists with content ==="
sudo ls -laR /run/secrets* 2>/dev/null || echo "No secrets directories"

echo ""
echo "=== Test manual SOPS decrypt ==="
cd /home/danny/git/dotfiles-nix
nix-shell -p sops --run "SOPS_AGE_KEY_FILE=/home/danny/.config/sops/age/keys.txt sops -d modules/nixos/security/sops/common.yaml" | grep -E "nordvpn|titan" | head -5