#!/usr/bin/env bash

echo "=== Manual VPN Connection Test ==="
echo ""

# Stop the service first
echo "Stopping wgnord service..."
sudo systemctl stop wgnord

# Disconnect any existing connection
echo "Disconnecting any existing VPN..."
sudo wgnord d 2>/dev/null

# Remove the broken config
echo "Removing broken config..."
sudo rm -f /etc/wireguard/wgnord.conf

# Check credentials exist
echo ""
echo "Checking credentials..."
if [ -f /var/lib/wgnord/credentials.json ]; then
    echo "✓ Credentials file exists"
    sudo cat /var/lib/wgnord/credentials.json | grep -o '"nordlynx_private_key":[^,]*' | head -1
else
    echo "✗ No credentials found"
fi

echo ""
echo "Attempting manual connection to P2P servers..."
sudo wgnord c p2p

echo ""
echo "Checking connection..."
sleep 3

echo ""
echo "WireGuard status:"
sudo wg show wgnord 2>/dev/null | head -5 || echo "No WireGuard interface"

echo ""
echo "Config file check:"
if [ -f /etc/wireguard/wgnord.conf ]; then
    echo "Config exists. Checking for real values:"
    sudo grep -E "PrivateKey|Address" /etc/wireguard/wgnord.conf | head -2
fi

echo ""
echo "Your public IP:"
curl -s ifconfig.me && echo ""

echo ""
echo "To make this permanent, we need to fix the systemd service."