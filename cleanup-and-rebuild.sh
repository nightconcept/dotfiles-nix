#!/usr/bin/env bash

echo "Cleaning up broken secrets symlinks and rebuilding..."

# Clean up any existing secrets
sudo rm -rf /run/secrets
sudo rm -rf /run/.secrets*

echo "Rebuilding NixOS configuration..."
sudo nixos-rebuild switch --flake .#barrett

echo ""
echo "Checking service status..."
sleep 2

# Check services
echo "=== wgnord service status ==="
systemctl status wgnord --no-pager | head -10

echo ""
echo "=== qBittorrent service status ==="
systemctl status qbittorrent --no-pager | head -10

echo ""
echo "=== Secrets deployment ==="
ls -la /run/secrets/ 2>/dev/null || echo "No secrets deployed"

echo ""
echo "Done!"