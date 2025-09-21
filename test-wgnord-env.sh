#!/usr/bin/env bash

echo "=== Testing wgnord with proper environment ==="
echo ""

# Stop service
sudo systemctl stop wgnord

# Clean up
sudo wgnord d 2>/dev/null
sudo rm -f /etc/wireguard/wgnord.conf

echo "Setting up environment like systemd would..."
export PATH="/run/current-system/sw/bin:$PATH"

echo ""
echo "PATH includes:"
echo "$PATH" | tr ':' '\n' | grep -E "jq|wireguard|iproute"

echo ""
echo "Testing jq availability:"
which jq && jq --version || echo "jq not found"

echo ""
echo "Testing wgnord with full path:"
sudo /run/current-system/sw/bin/wgnord c p2p

echo ""
echo "Checking result:"
if sudo wg show wgnord 2>/dev/null | grep -q interface; then
    echo "✓ Connected successfully!"
    echo ""
    echo "Public IP:"
    curl -s ifconfig.me && echo ""
else
    echo "✗ Connection failed"
    echo ""
    echo "Config file content:"
    sudo cat /etc/wireguard/wgnord.conf 2>/dev/null | grep -E "PrivateKey|Address" | head -3
fi