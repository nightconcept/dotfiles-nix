#!/usr/bin/env bash
#
# Setup SSH keys from Titan mount
# This script copies SSH keys from the Titan NAS mount and configures them for:
# - SSH authentication
# - Git commit signing
# - Remote access authorization

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TITAN_SSH_DIR="/mnt/titan/transfer/.ssh"
LOCAL_SSH_DIR="$HOME/.ssh"
SSH_KEY_NAME="id_sdev"

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Titan is mounted
check_titan_mount() {
    if [ ! -d "$TITAN_SSH_DIR" ]; then
        print_error "Titan mount not found at $TITAN_SSH_DIR"
        print_info "Please ensure Titan is mounted first:"
        print_info "  sudo mkdir -p /mnt/titan"
        print_info "  sudo mount -t cifs //titan/transfer /mnt/titan/transfer -o credentials=/path/to/credentials"
        exit 1
    fi
    print_info "Titan mount found ✓"
}

# Check if SSH keys exist on Titan
check_keys_exist() {
    if [ ! -f "$TITAN_SSH_DIR/$SSH_KEY_NAME" ] || [ ! -f "$TITAN_SSH_DIR/$SSH_KEY_NAME.pub" ]; then
        print_error "SSH keys not found on Titan at $TITAN_SSH_DIR/$SSH_KEY_NAME"
        print_info "Expected files:"
        print_info "  - $TITAN_SSH_DIR/$SSH_KEY_NAME"
        print_info "  - $TITAN_SSH_DIR/$SSH_KEY_NAME.pub"
        exit 1
    fi
    print_info "SSH keys found on Titan ✓"
}

# Create SSH directory with proper permissions
setup_ssh_directory() {
    print_info "Setting up SSH directory..."
    mkdir -p "$LOCAL_SSH_DIR"
    chmod 700 "$LOCAL_SSH_DIR"
    print_info "SSH directory created with permissions 700 ✓"
}

# Copy SSH keys from Titan
copy_ssh_keys() {
    print_info "Copying SSH keys from Titan..."
    
    # Copy private key
    cp "$TITAN_SSH_DIR/$SSH_KEY_NAME" "$LOCAL_SSH_DIR/"
    chmod 600 "$LOCAL_SSH_DIR/$SSH_KEY_NAME"
    print_info "Private key copied and secured (600) ✓"
    
    # Copy public key
    cp "$TITAN_SSH_DIR/$SSH_KEY_NAME.pub" "$LOCAL_SSH_DIR/"
    chmod 644 "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub"
    print_info "Public key copied (644) ✓"
}

# Setup authorized_keys for incoming SSH
setup_authorized_keys() {
    print_info "Setting up authorized_keys for SSH access..."
    
    # Read the public key
    PUBLIC_KEY=$(cat "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub")
    
    # Add to authorized_keys if not already present
    if [ -f "$LOCAL_SSH_DIR/authorized_keys" ]; then
        if grep -q "$PUBLIC_KEY" "$LOCAL_SSH_DIR/authorized_keys"; then
            print_warn "Key already in authorized_keys, skipping"
        else
            echo "$PUBLIC_KEY" >> "$LOCAL_SSH_DIR/authorized_keys"
            print_info "Added key to existing authorized_keys ✓"
        fi
    else
        echo "$PUBLIC_KEY" > "$LOCAL_SSH_DIR/authorized_keys"
        print_info "Created authorized_keys with key ✓"
    fi
    
    chmod 600 "$LOCAL_SSH_DIR/authorized_keys"
}

# Setup Git SSH signing
setup_git_signing() {
    print_info "Setting up Git SSH signing..."
    
    # Get email from Git config or use default
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "dark@nightconcept.net")
    
    # Create allowed_signers file for Git
    echo "$GIT_EMAIL $(cat "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub")" > "$LOCAL_SSH_DIR/allowed_signers"
    chmod 644 "$LOCAL_SSH_DIR/allowed_signers"
    print_info "Created allowed_signers file ✓"
    
    # Configure Git to use SSH signing (if not using Nix home-manager)
    if ! command -v home-manager &> /dev/null; then
        print_info "Configuring Git for SSH signing..."
        git config --global gpg.format ssh
        git config --global user.signingkey "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub"
        git config --global gpg.ssh.allowedSignersFile "$LOCAL_SSH_DIR/allowed_signers"
        git config --global commit.gpgsign true
        print_info "Git configured for SSH signing ✓"
    else
        print_info "Git SSH signing should be configured via home-manager (git.nix)"
    fi
}

# Test SSH key
test_ssh_key() {
    print_info "Testing SSH key..."
    
    # Test if key is valid
    if ssh-keygen -l -f "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub" &> /dev/null; then
        print_info "SSH key is valid ✓"
        
        # Show key fingerprint
        FINGERPRINT=$(ssh-keygen -l -f "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub")
        print_info "Key fingerprint: $FINGERPRINT"
    else
        print_error "SSH key validation failed"
        exit 1
    fi
}

# Main execution
main() {
    echo "========================================="
    echo "     SSH Key Setup from Titan Mount     "
    echo "========================================="
    echo
    
    # Run all setup steps
    check_titan_mount
    check_keys_exist
    setup_ssh_directory
    copy_ssh_keys
    setup_authorized_keys
    setup_git_signing
    test_ssh_key
    
    echo
    print_info "${GREEN}Setup completed successfully! 🎉${NC}"
    echo
    print_info "SSH keys have been configured for:"
    print_info "  • SSH authentication (client)"
    print_info "  • SSH access to this machine (server)"
    print_info "  • Git commit signing"
    echo
    print_info "To test Git signing:"
    print_info "  git commit --allow-empty -m 'Test SSH signing'"
    print_info "  git log --show-signature -1"
    echo
    print_info "To test SSH access:"
    print_info "  ssh localhost"
}

# Run main function
main "$@"