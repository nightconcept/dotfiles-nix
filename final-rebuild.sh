#!/usr/bin/env bash

echo "Final rebuild with all fixes..."
echo ""

# Create wireguard directory manually for immediate fix
echo "Creating /etc/wireguard directory..."
sudo mkdir -p /etc/wireguard
sudo chmod 755 /etc/wireguard

echo "Rebuilding NixOS configuration..."
sudo nixos-rebuild switch --flake .#barrett

echo ""
echo "Waiting for services to start..."
sleep 5

echo ""
echo "=== Service Status ==="
echo "wgnord (NordVPN):"
systemctl status wgnord --no-pager | head -10

echo ""
echo "qBittorrent:"
systemctl status qbittorrent --no-pager | head -10

echo ""
echo "Network mount (titan):"
systemctl status mnt-titan.mount --no-pager | head -10

echo ""
echo "=== Checking VPN Connection ==="
if ip link show wgnord &>/dev/null; then
    echo "✓ WireGuard interface is up"
    echo "Public IP: $(curl -s ifconfig.me 2>/dev/null || echo "Unable to check")"
else
    echo "✗ WireGuard interface not found"
fi

echo ""
echo "=== Checking Network Mount ==="
if mountpoint -q /mnt/titan; then
    echo "✓ Titan network drive is mounted"
    ls -la /mnt/titan | head -5
else
    echo "✗ Titan network drive not mounted"
fi

echo ""
echo "Done! Check service status above."