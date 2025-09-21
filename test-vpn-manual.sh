#!/usr/bin/env bash

echo "=== Manual VPN Connection Test ==="

# Check credentials
echo "Checking credentials..."
if [ -f /var/lib/wgnord/credentials.json ]; then
    PRIVKEY=$(sudo cat /var/lib/wgnord/credentials.json | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.nordlynx_private_key')
    echo "Private key found: ${PRIVKEY:0:10}..."
else
    echo "No credentials found!"
    exit 1
fi

echo ""
echo "Getting server info..."
SERVER_INFO=$(curl -s "https://api.nordvpn.com/v1/servers/recommendations?filters[servers_technologies][identifier]=wireguard_udp&filters[country_id]=228&limit=1")

if [ -z "$SERVER_INFO" ] || [ "$SERVER_INFO" = "[]" ]; then
    echo "Failed to get server info"
    exit 1
fi

SERVER_IP=$(echo "$SERVER_INFO" | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.[0].station')
SERVER_PUBKEY=$(echo "$SERVER_INFO" | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.[0].technologies[] | select(.identifier == "wireguard_udp") | .metadata[0].value')
SERVER_NAME=$(echo "$SERVER_INFO" | /nix/store/7jvwwz45qap70i6asxzcnbshhz88a5sv-jq-1.8.1-bin/bin/jq -r '.[0].hostname')

echo "Server: $SERVER_NAME ($SERVER_IP)"
echo "Server public key: ${SERVER_PUBKEY:0:20}..."

echo ""
echo "Creating config..."
sudo tee /etc/wireguard/wgnord.conf > /dev/null << EOF
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

echo "Config created. Checking content:"
sudo grep -E "PrivateKey|PublicKey|Endpoint" /etc/wireguard/wgnord.conf | head -3

echo ""
echo "Bringing up interface..."
sudo wg-quick up wgnord

echo ""
echo "Checking connection..."
sleep 2
echo "Public IP: $(curl -s ifconfig.me)"
curl -s ipinfo.io | grep -E '"org"'