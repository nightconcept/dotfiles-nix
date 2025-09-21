#!/usr/bin/env bash

# Workaround script for wgnord systemd service
# The wgnord script has issues substituting credentials when run from systemd

set -e

echo "Starting wgnord workaround..."

# Ensure we're root
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

# Clean up any existing connection
wgnord d 2>/dev/null || true
wg-quick down wgnord 2>/dev/null || true
rm -f /etc/wireguard/wgnord.conf

# Get credentials
if [ ! -f /var/lib/wgnord/credentials.json ]; then
    echo "Error: No credentials found. Please login first."
    exit 1
fi

# Use nix-shell to ensure we have jq and curl
export PATH="/nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin:$PATH"

# Extract credentials using jq (use the path from wgnord itself)
PRIVKEY=$(cat /var/lib/wgnord/credentials.json | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.nordlynx_private_key')

# Find a good server
echo "Finding best P2P server..."
# URL encode the square brackets
SERVER_INFO=$(curl -s "https://api.nordvpn.com/v1/servers/recommendations?filters%5Bservers_technologies%5D%5Bidentifier%5D=wireguard_udp&filters%5Bservers_groups%5D%5Bidentifier%5D=legacy_p2p&limit=1")

if [ -z "$SERVER_INFO" ] || [ "$SERVER_INFO" = "[]" ]; then
    echo "Failed to get P2P server info, trying regular US servers..."
    SERVER_INFO=$(curl -s "https://api.nordvpn.com/v1/servers/recommendations?filters%5Bservers_technologies%5D%5Bidentifier%5D=wireguard_udp&filters%5Bcountry_id%5D=228&limit=1")
fi

SERVER_IP=$(echo "$SERVER_INFO" | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.[0].station')
SERVER_PUBKEY=$(echo "$SERVER_INFO" | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.[0].technologies[] | select(.identifier == "wireguard_udp") | .metadata[0].value')
SERVER_NAME=$(echo "$SERVER_INFO" | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.[0].hostname')

echo "Connecting to $SERVER_NAME..."

# Create WireGuard config
cat > /etc/wireguard/wgnord.conf << EOF
[Interface]
PrivateKey = $PRIVKEY
Address = 10.5.0.2/16
DNS = 103.86.96.100,103.86.99.100
MTU = 1420

[Peer]
PublicKey = $SERVER_PUBKEY
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${SERVER_IP}:51820
EOF

chmod 600 /etc/wireguard/wgnord.conf

# Bring up the interface
wg-quick up wgnord

echo "Connected successfully!"

# Verify connection
sleep 2
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Your public IP is now: $PUBLIC_IP"

if curl -s ipinfo.io | grep -q "Nord"; then
    echo "✓ Successfully connected through NordVPN!"
else
    echo "Warning: May not be connected through NordVPN"
fi