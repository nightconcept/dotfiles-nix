#!/usr/bin/env bash

echo "=== Debugging wgnord ==="
echo ""

# Check credentials file
echo "Credentials file content:"
sudo cat /var/lib/wgnord/credentials.json | python3 -m json.tool

echo ""
echo "Testing credential extraction:"
PRIVKEY=$(sudo cat /var/lib/wgnord/credentials.json | jq -r '.nordlynx_private_key')
echo "Private key extracted: ${PRIVKEY:0:10}..."

echo ""
echo "Looking at wgnord script to find the issue..."
# Find where wgnord processes the config
sudo grep -A5 -B5 "template.conf" /nix/store/*/bin/wgnord 2>/dev/null | head -20

echo ""
echo "Checking if jq is available to wgnord:"
which jq

echo ""
echo "Let's try a different approach - use the official NordVPN API directly..."