#!/usr/bin/env bash

echo "=== Final VPN Fix with Dependencies ==="
echo ""

# Stop any existing connection
echo "Stopping existing services..."
sudo systemctl stop wgnord
sudo wgnord d 2>/dev/null
sudo rm -f /etc/wireguard/wgnord.conf

echo ""
echo "Rebuilding with fixed dependencies..."
sudo nixos-rebuild switch --flake .#barrett

echo ""
echo "Waiting for service to start..."
sleep 10

echo ""
echo "=== Service Status ==="
systemctl status wgnord --no-pager | grep -E "Active:|Main PID:" | head -2

echo ""
echo "=== Checking VPN Connection ==="
echo "WireGuard interface:"
sudo wg show wgnord 2>/dev/null | head -5 || echo "No active connection"

echo ""
echo "Interface details:"
ip addr show wgnord 2>/dev/null | grep inet || echo "No IP assigned"

echo ""
echo "Your public IP (should be NordVPN):"
PUBLIC_IP=$(curl -s ifconfig.me)
echo "$PUBLIC_IP"

echo ""
echo "Checking if it's NordVPN:"
curl -s ipinfo.io | grep -E '"org"' | grep -q "Nord" && echo "✓ Connected through NordVPN!" || echo "✗ Not on VPN"

echo ""
echo "Full location info:"
curl -s ipinfo.io | python3 -m json.tool | grep -E '"ip"|"city"|"region"|"country"|"org"'

echo ""
echo "=== All Services Status ==="
echo "wgnord: $(systemctl is-active wgnord)"
echo "qBittorrent: $(systemctl is-active qbittorrent)"
echo "Titan mount: $(mountpoint -q /mnt/titan && echo 'mounted' || echo 'not mounted')"

echo ""
echo "Done! Your torrents should now go through NordVPN."