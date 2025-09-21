#!/usr/bin/env bash

echo "=== VPN Status Check ==="
echo ""

# Check WireGuard interface
echo "WireGuard interface:"
sudo wg show wgnord 2>/dev/null | head -5 || echo "No WireGuard config found"

echo ""
echo "Interface details:"
ip addr show wgnord 2>/dev/null | grep -E "inet|state" || echo "Interface not found"

echo ""
echo "Routing table:"
ip route | grep wgnord | head -5

echo ""
echo "DNS servers:"
resolvectl status 2>/dev/null | grep -A3 "Link.*wgnord" || cat /etc/resolv.conf | head -5

echo ""
echo "=== Testing VPN effectiveness ==="
echo "Your public IP:"
curl -s ifconfig.me && echo ""

echo ""
echo "IP location check:"
curl -s ipinfo.io | grep -E '"ip"|"city"|"country"' | head -5

echo ""
echo "Torrent IP check (what torrents will see):"
curl -s https://api.ipify.org && echo ""

echo ""
echo "=== qBittorrent Status ==="
echo "Service: $(systemctl is-active qbittorrent)"
echo "Web UI should be available at: http://$(hostname -I | awk '{print $1}'):8080"
echo "Default login: danny / changeme"