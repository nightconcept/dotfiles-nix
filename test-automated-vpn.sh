#!/usr/bin/env bash

echo "=== Testing Automated VPN Connection ==="
echo ""

# First disconnect any existing connection
echo "Disconnecting any existing VPN..."
sudo wgnord d 2>/dev/null

# Remove any bad config
sudo rm -f /etc/wireguard/wgnord.conf

echo ""
echo "Rebuilding NixOS with fixed VPN service..."
sudo nixos-rebuild switch --flake .#barrett

echo ""
echo "Waiting for services to start..."
sleep 5

echo ""
echo "=== Checking VPN Status ==="

# Check service
echo "Service status:"
systemctl status wgnord --no-pager | grep -E "Active:|Main PID:" | head -2

echo ""
echo "WireGuard interface:"
sudo wg show wgnord 2>/dev/null | head -5 || echo "No active WireGuard connection"

echo ""
echo "Interface IP:"
ip addr show wgnord 2>/dev/null | grep inet || echo "No IP address assigned"

echo ""
echo "=== Connection Test ==="
echo "Your public IP:"
PUBLIC_IP=$(curl -s ifconfig.me)
echo "$PUBLIC_IP"

echo ""
echo "IP location:"
curl -s ipinfo.io | grep -E '"ip"|"city"|"org"' | head -5

echo ""
# Check if it's a NordVPN IP
if curl -s ipinfo.io | grep -q "Nord\|NordVPN"; then
    echo "✓ Connected through NordVPN!"
else
    echo "✗ Not connected through NordVPN"
    echo ""
    echo "Checking logs for issues:"
    journalctl -u wgnord -n 20 --no-pager | grep -E "ERROR|Warning|Failed|Connected"
fi

echo ""
echo "=== Services Check ==="
systemctl is-active wgnord && echo "✓ wgnord is active" || echo "✗ wgnord is not active"
systemctl is-active qbittorrent && echo "✓ qBittorrent is active" || echo "✗ qBittorrent is not active"

echo ""
echo "Done!"