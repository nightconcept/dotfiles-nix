#!/usr/bin/env bash
#
# Setup SSH keys from Titan mount or use existing keys
# This script copies SSH keys from the Titan NAS mount (if available) and configures them for:
# - SSH authentication
# - Git commit signing
# - Remote access authorization
# - Age key generation for sops-nix

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TITAN_SSH_DIR="/mnt/titan/transfer/.ssh"
LOCAL_SSH_DIR="$HOME/.ssh"
SSH_KEY_NAME="id_sdev"
AGE_KEY_DIR="$HOME/.config/sops/age"
AGE_KEY_PATH="$AGE_KEY_DIR/keys.txt"
SOPS_CONFIG=".sops.yaml"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if dotfiles directory context is correct for sops
check_dotfiles_context() {
    if [[ ! -f "$SOPS_CONFIG" ]]; then
        print_error "This script must be run from the dotfiles-nix directory"
        print_info "Please cd to your dotfiles-nix directory and run again"
        exit 1
    fi
}

# Check if Titan is mounted and keys are available
check_titan_availability() {
    TITAN_AVAILABLE=false

    if [ ! -d "$TITAN_SSH_DIR" ]; then
        print_warn "Titan mount not found at $TITAN_SSH_DIR"
        print_info "Will attempt to use existing SSH keys if available"
        return 1
    fi

    if [ ! -f "$TITAN_SSH_DIR/$SSH_KEY_NAME" ] || [ ! -f "$TITAN_SSH_DIR/$SSH_KEY_NAME.pub" ]; then
        print_warn "SSH keys not found on Titan at $TITAN_SSH_DIR/$SSH_KEY_NAME"
        print_info "Will attempt to use existing SSH keys if available"
        return 1
    fi

    print_info "Titan mount and SSH keys found ✓"
    TITAN_AVAILABLE=true
    return 0
}

# Check if SSH keys exist locally
check_local_keys_exist() {
    if [ ! -f "$LOCAL_SSH_DIR/$SSH_KEY_NAME" ] || [ ! -f "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub" ]; then
        print_error "SSH keys not found locally at $LOCAL_SSH_DIR/$SSH_KEY_NAME"
        print_info "Expected files:"
        print_info "  - $LOCAL_SSH_DIR/$SSH_KEY_NAME"
        print_info "  - $LOCAL_SSH_DIR/$SSH_KEY_NAME.pub"
        return 1
    fi
    print_info "Local SSH keys found ✓"
    return 0
}

# Create SSH directory with proper permissions
setup_ssh_directory() {
    print_info "Setting up SSH directory..."
    mkdir -p "$LOCAL_SSH_DIR"
    chmod 700 "$LOCAL_SSH_DIR"
    print_info "SSH directory created with permissions 700 ✓"
}

# Copy SSH keys from Titan (if available)
copy_ssh_keys() {
    if [ "$TITAN_AVAILABLE" = true ]; then
        print_info "Copying SSH keys from Titan..."

        # Copy private key
        cp "$TITAN_SSH_DIR/$SSH_KEY_NAME" "$LOCAL_SSH_DIR/"
        chmod 600 "$LOCAL_SSH_DIR/$SSH_KEY_NAME"
        print_info "Private key copied and secured (600) ✓"

        # Copy public key
        cp "$TITAN_SSH_DIR/$SSH_KEY_NAME.pub" "$LOCAL_SSH_DIR/"
        chmod 644 "$LOCAL_SSH_DIR/$SSH_KEY_NAME.pub"
        print_info "Public key copied (644) ✓"
    else
        print_info "Using existing local SSH keys"
    fi
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

# Setup age key for sops-nix
setup_age_key() {
    print_info "Setting up age key from SSH key for sops-nix..."

    # Run the age key generation in a nix shell
    nix-shell -p ssh-to-age --run bash << 'EOF'
set -euo pipefail

# Configuration (redefined inside nix-shell)
SSH_KEY_PATH="$HOME/.ssh/id_sdev"
AGE_KEY_DIR="$HOME/.config/sops/age"
AGE_KEY_PATH="$AGE_KEY_DIR/keys.txt"

# Color codes for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Create age key directory if it doesn't exist
if [[ ! -d "$AGE_KEY_DIR" ]]; then
    print_info "Creating age key directory at $AGE_KEY_DIR"
    mkdir -p "$AGE_KEY_DIR"
fi

# Check if age key already exists
if [[ -f "$AGE_KEY_PATH" ]]; then
    print_warning "Age key already exists at $AGE_KEY_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing age key"
        exit 0
    fi
fi

# Convert SSH key to age key
print_info "Converting SSH key to age key..."
if ssh-to-age -private-key -i "$SSH_KEY_PATH" > "$AGE_KEY_PATH" 2>/dev/null; then
    print_success "Age key successfully created at $AGE_KEY_PATH"

    # Set proper permissions
    chmod 600 "$AGE_KEY_PATH"
    print_info "Set permissions to 600 for age key"
else
    print_error "Failed to convert SSH key to age key"
    print_info "Please check that your SSH key is valid"
    exit 1
fi

# Get the age public key for display
AGE_PUBLIC_KEY=$(ssh-to-age < "$SSH_KEY_PATH.pub" 2>/dev/null || echo "Could not derive public key")

print_success "Age key setup complete!"
echo
print_info "Age public key (for .sops.yaml):"
echo "  $AGE_PUBLIC_KEY"
echo
print_info "The age key will be used automatically by sops-nix to decrypt secrets"
EOF

    if [ $? -eq 0 ]; then
        print_success "Age key setup completed ✓"
    else
        print_error "Age key setup failed"
        return 1
    fi
}

# Main execution
main() {
    echo "========================================="
    echo "  SSH & Age Key Setup from Titan/Local  "
    echo "========================================="
    echo

    # Check dotfiles context first
    check_dotfiles_context

    # Check if Titan is available, but don't exit if not
    check_titan_availability

    # Setup SSH directory
    setup_ssh_directory

    # Try to copy from Titan or verify local keys exist
    if [ "$TITAN_AVAILABLE" = true ]; then
        copy_ssh_keys
    else
        if ! check_local_keys_exist; then
            print_error "No SSH keys available from Titan or locally"
            print_info "Please ensure SSH keys are available either:"
            print_info "  1. Mount Titan with keys at $TITAN_SSH_DIR"
            print_info "  2. Have existing keys at $LOCAL_SSH_DIR"
            exit 1
        fi
    fi

    # Continue with setup steps
    setup_authorized_keys
    setup_git_signing
    test_ssh_key
    setup_age_key

    echo
    print_success "Setup completed successfully! 🎉"
    echo
    print_info "Keys have been configured for:"
    print_info "  • SSH authentication (client)"
    print_info "  • SSH access to this machine (server)"
    print_info "  • Git commit signing"
    print_info "  • Age key encryption (sops-nix)"
    echo
    print_info "Next steps:"
    echo "  1. Ensure the age public key above matches what's in your .sops.yaml file"
    echo "  2. Rebuild your NixOS/home-manager configuration:"
    echo "     - For NixOS: sudo nixos-rebuild switch --flake .#<hostname>"
    echo "     - For home-manager: home-manager switch --flake .#<config>"
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