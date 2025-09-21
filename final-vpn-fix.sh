#!/usr/bin/env bash

echo "=== Final VPN Fix ==="
echo ""

# Setup template file manually for immediate fix
echo "Setting up wgnord template file..."
sudo bash -c 'cat > /var/lib/wgnord/template.conf << "EOF"
[Interface]
PrivateKey = <privatekey>
Address = <address>
DNS = 103.86.96.100,103.86.99.100
MTU = 1420

[Peer]
PublicKey = <publickey>
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = <endpoint>
EOF'

echo "Template file created."

# Rebuild to apply module changes
echo ""
echo "Rebuilding NixOS configuration..."
sudo nixos-rebuild switch --flake .#barrett

echo ""
echo "Restarting VPN service..."
sudo systemctl restart wgnord

echo ""
echo "Waiting for connection..."
sleep 5

echo ""
echo "=== VPN Status Check ==="

# Check if VPN is working
echo "WireGuard interface:"
sudo wg show wgnord 2>/dev/null | head -5 || echo "No active connection"

echo ""
echo "Interface IP:"
ip addr show wgnord 2>/dev/null | grep inet || echo "No IP assigned"

echo ""
echo "Your public IP (should be VPN):"
curl -s ifconfig.me && echo ""

echo ""
echo "Location info:"
curl -s ipinfo.io | grep -E '"ip"|"city"|"org"'

echo ""
echo "=== Service Status ==="
systemctl is-active wgnord && echo "✓ wgnord is active" || echo "✗ wgnord is not active"
systemctl is-active qbittorrent && echo "✓ qBittorrent is active" || echo "✗ qBittorrent is not active"

echo ""
echo "Done! Check if the public IP shows a NordVPN server."
echo "If not connected, check: journalctl -u wgnord -f"