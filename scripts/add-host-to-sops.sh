#!/usr/bin/env bash
# Script to add a new host's SSH key to sops configuration

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <hostname> <host-ssh-key-path-or-ssh-destination>"
    echo "Examples:"
    echo "  $0 aerith /etc/ssh/ssh_host_ed25519_key.pub"
    echo "  $0 aerith root@aerith"
    echo "  $0 waver ~/.ssh/id_ed25519.pub  # For macOS hosts using personal key"
    exit 1
fi

HOSTNAME=$1
KEY_SOURCE=$2
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Adding host $HOSTNAME to sops configuration..."

# Get the age public key
if [[ "$KEY_SOURCE" == *"@"* ]]; then
    # SSH to remote host to get key
    echo "Getting SSH host key from $KEY_SOURCE..."
    AGE_KEY=$(ssh "$KEY_SOURCE" "cat /etc/ssh/ssh_host_ed25519_key.pub" | nix-shell -p ssh-to-age --run "ssh-to-age")
elif [ -f "$KEY_SOURCE" ]; then
    # Local file
    echo "Converting local key $KEY_SOURCE to age format..."
    AGE_KEY=$(nix-shell -p ssh-to-age --run "ssh-to-age < $KEY_SOURCE")
else
    echo "Error: $KEY_SOURCE is not a file or SSH destination"
    exit 1
fi

echo "Age public key for $HOSTNAME: $AGE_KEY"

# Add to .sops.yaml
echo ""
echo "Add this line to the 'keys:' section in $DOTFILES_ROOT/.sops.yaml:"
echo "  - &${HOSTNAME}_host $AGE_KEY"
echo ""
echo "Then add '- *${HOSTNAME}_host' to the appropriate creation_rules sections."
echo ""
echo "After updating .sops.yaml, run:"
echo "  cd $DOTFILES_ROOT"
echo "  nix-shell -p sops --run 'sops updatekeys secrets/common.yaml'"
echo "  nix-shell -p sops --run 'sops updatekeys secrets/user.yaml'"
echo ""
echo "For macOS hosts using home-manager only, you'll need to:"
echo "1. Copy ~/.config/sops/age/keys.txt to the macOS machine"
echo "2. Add the host to the appropriate creation_rules in .sops.yaml"