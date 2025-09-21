#!/usr/bin/env bash

echo "=== Restarting VPN Service ==="

# Create template directory if missing
echo "Creating wgnord directories..."
sudo mkdir -p /var/lib/wgnord
sudo mkdir -p /etc/wireguard

# Stop the service first
echo "Stopping wgnord..."
sudo systemctl stop wgnord

# Remove old config if exists
sudo rm -f /etc/wireguard/wgnord.conf

# Restart the service
echo "Starting wgnord..."
sudo systemctl start wgnord

# Wait for connection
echo "Waiting for VPN connection..."
sleep 5

# Check status
echo ""
echo "=== VPN Status ==="
systemctl status wgnord --no-pager | head -10

echo ""
echo "=== WireGuard Interface ==="
sudo wg show wgnord 2>/dev/null | head -10 || echo "No active connection"

echo ""
echo "=== IP Address Check ==="
echo "Interface IP:"
ip addr show wgnord 2>/dev/null | grep inet || echo "No IP assigned"

echo ""
echo "Public IP (should be VPN):"
curl -s ifconfig.me && echo ""

echo ""
echo "Location:"
curl -s ipinfo.io | grep -E '"city"|"org"' | head -5