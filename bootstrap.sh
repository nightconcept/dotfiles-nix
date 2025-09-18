#!/usr/bin/env bash
#
# Universal Bootstrap Script for Nix Dotfiles
# 
# Usage:
#   curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
#   # OR
#   wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
#
# Supports:
#   - NixOS (with host selection for tidus/aerith)
#   - Linux distros (Ubuntu, Fedora, Arch, SUSE, Alpine, etc.)
#   - macOS (partial - manual steps required)
#
# Features:
#   - Auto-detects OS and package manager
#   - Installs Nix if not present
#   - Clones dotfiles repository
#   - On NixOS: Offers to switch to a specific host configuration
#   - On Linux: Sets up Home Manager with profile selection
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLAKE_REPO="https://github.com/nightconcept/dotfiles-nix"
FLAKE_DIR="$HOME/git/dotfiles-nix"

# Print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS/Distro
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "nixos" ]]; then
            echo "nixos"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v apk &> /dev/null; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# Install prerequisites based on package manager
install_prerequisites() {
    local pkg_manager=$1
    
    print_info "Installing prerequisites..."
    
    case "$pkg_manager" in
        apt)
            sudo apt-get update
            sudo apt-get install -y curl git xz-utils
            ;;
        dnf|yum)
            sudo ${pkg_manager} install -y curl git xz
            ;;
        pacman)
            sudo pacman -Syu --noconfirm curl git xz
            ;;
        zypper)
            sudo zypper install -y curl git xz
            ;;
        apk)
            sudo apk add --no-cache curl git xz
            ;;
        *)
            print_warning "Unknown package manager. Please ensure curl, git, and xz are installed."
            read -p "Continue anyway? (y/n): " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
            ;;
    esac
}

# Install Nix on non-NixOS systems
install_nix() {
    if command -v nix &> /dev/null; then
        print_info "Nix is already installed"
        return
    fi
    
    print_info "Installing Nix..."
    
    # Try Determinate Systems installer first (recommended)
    if curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install; then
        print_success "Nix installed via Determinate Systems installer"
    else
        # Fallback to official installer
        print_warning "Determinate installer failed, trying official installer..."
        sh <(curl -L https://nixos.org/nix/install) --daemon
    fi
    
    # Source Nix
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    
    # Add user to trusted users
    if [[ -f /etc/nix/nix.conf ]]; then
        if ! grep -q "trusted-users.*$USER" /etc/nix/nix.conf; then
            print_info "Adding $USER to trusted users..."
            echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf
        fi
    fi
}

# Clone flake repository
clone_flake() {
    if [[ -d "$FLAKE_DIR" ]]; then
        print_info "Flake directory already exists at $FLAKE_DIR"
        read -p "Pull latest changes? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$FLAKE_DIR"
            git pull
        fi
    else
        print_info "Cloning flake repository..."
        mkdir -p "$(dirname "$FLAKE_DIR")"
        git clone "$FLAKE_REPO" "$FLAKE_DIR"
    fi
    cd "$FLAKE_DIR"
}

# NixOS host selection menu
select_nixos_host() {
    print_info "Available NixOS configurations:"
    echo "  1) tidus   - Dell Latitude 7420 laptop"
    echo "  2) aerith  - Plex media server"
    echo "  3) barrett - VPN torrent server"
    echo "  4) Skip    - Don't switch configuration"
    echo
    
    read -p "Select configuration (1-4): " -n 1 -r
    echo
    
    case "$REPLY" in
        1)
            echo "tidus"
            ;;
        2)
            echo "aerith"
            ;;
        3)
            echo "barrett"
            ;;
        4)
            echo "skip"
            ;;
        *)
            print_error "Invalid selection"
            select_nixos_host
            ;;
    esac
}

# Setup SOPS age keys
setup_age_keys() {
    print_info "Setting up SOPS age keys..."
    
    # Create age directory
    mkdir -p "$HOME/.config/sops/age"
    
    # Check if age key already exists
    if [[ -f "$HOME/.config/sops/age/keys.txt" ]]; then
        print_info "Age key file already exists"
        return
    fi
    
    print_info "Age key is required for accessing encrypted secrets (SOPS)"
    print_info "You can either:"
    echo "  1) Enter an existing age key"
    echo "  2) Generate a new age key (will need to be added to .sops.yaml)"
    echo "  3) Skip (secrets won't work until configured later)"
    echo
    
    read -p "Select option (1-3): " -n 1 -r
    echo
    
    case "$REPLY" in
        1)
            echo "Enter your age private key (starts with AGE-SECRET-KEY):"
            read -r age_key
            if [[ "$age_key" =~ ^AGE-SECRET-KEY ]]; then
                echo "$age_key" > "$HOME/.config/sops/age/keys.txt"
                chmod 600 "$HOME/.config/sops/age/keys.txt"
                print_success "Age key saved successfully"
            else
                print_error "Invalid age key format"
                return 1
            fi
            ;;
        2)
            if command -v age-keygen &> /dev/null; then
                age-keygen -o "$HOME/.config/sops/age/keys.txt"
                print_success "New age key generated"
                print_warning "You'll need to add the public key to .sops.yaml for secrets access"
                print_info "Public key: $(age-keygen -y "$HOME/.config/sops/age/keys.txt")"
            else
                print_error "age-keygen not available. Install age package first."
                return 1
            fi
            ;;
        3)
            print_warning "Skipping age key setup. Secrets won't work until configured."
            return
            ;;
        *)
            print_error "Invalid selection"
            setup_age_keys
            ;;
    esac
}

# Apply NixOS configuration
apply_nixos_config() {
    local host=$1
    
    print_info "Building and switching to NixOS configuration: $host"
    
    # Enable flakes if not already enabled
    if ! grep -q "experimental-features.*flakes" /etc/nix/nix.conf 2>/dev/null; then
        echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
    fi
    
    # Setup age keys before applying config
    setup_age_keys
    
    # Build and switch
    sudo nixos-rebuild switch --flake ".#$host"
    
    print_success "NixOS configuration applied!"
}

# Install Home Manager standalone
install_home_manager() {
    print_info "Setting up Home Manager..."
    
    # Check if home-manager is already available
    if command -v home-manager &> /dev/null; then
        print_info "Home Manager is already installed"
    else
        print_info "Installing Home Manager..."
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
        nix-shell '<home-manager>' -A install
    fi
}

# Apply Home Manager configuration
apply_home_config() {
    local profile=$1
    
    print_info "Available Home Manager profiles:"
    echo "  1) desktop - Full desktop environment"
    echo "  2) laptop  - Laptop configuration"
    echo "  3) server  - Minimal server configuration"
    echo "  4) Skip    - Don't apply Home Manager configuration"
    echo
    
    read -p "Select profile (1-4): " -n 1 -r
    echo
    
    case "$REPLY" in
        1)
            profile="desktop"
            ;;
        2)
            profile="laptop"
            ;;
        3)
            profile="server"
            ;;
        4)
            return
            ;;
        *)
            print_error "Invalid selection"
            apply_home_config
            return
            ;;
    esac
    
    print_info "Applying Home Manager configuration: $profile"
    home-manager switch --flake ".#$profile"
    print_success "Home Manager configuration applied!"
}

# Main installation flow
main() {
    clear
    echo "======================================"
    echo "   Nix Dotfiles Bootstrap Script"
    echo "======================================"
    echo
    
    # Detect OS
    OS=$(detect_os)
    print_info "Detected OS: $OS"
    
    case "$OS" in
        nixos)
            print_info "Running on NixOS"
            clone_flake
            
            # Ask if user wants to switch to a specific configuration
            host=$(select_nixos_host)
            if [[ "$host" != "skip" ]]; then
                apply_nixos_config "$host"
            else
                print_info "Skipping NixOS configuration"
            fi
            ;;
            
        linux)
            print_info "Running on Linux (non-NixOS)"
            
            # Detect and use package manager
            PKG_MANAGER=$(detect_package_manager)
            print_info "Detected package manager: $PKG_MANAGER"
            
            # Install prerequisites
            install_prerequisites "$PKG_MANAGER"
            
            # Install Nix
            install_nix
            
            # Clone flake
            clone_flake
            
            # Install and configure Home Manager
            install_home_manager
            apply_home_config
            ;;
            
        darwin)
            print_info "Running on macOS"
            print_warning "macOS support coming soon!"
            print_info "Please install Nix manually and run:"
            print_info "  nix-darwin switch --flake $FLAKE_REPO#waver  # for MacBook"
            print_info "  nix-darwin switch --flake $FLAKE_REPO#merlin # for Mac Mini"
            exit 0
            ;;
            
        *)
            print_error "Unsupported OS"
            exit 1
            ;;
    esac
    
    print_success "Bootstrap complete!"
    print_info "Please restart your shell or log out and back in to ensure all changes take effect."
    
    # Provide next steps
    echo
    echo "Next steps:"
    echo "  - Review the configuration in $FLAKE_DIR"
    echo "  - Make any necessary adjustments for your system"
    echo "  - Commit your changes if you've made modifications"
    
    if [[ "$OS" == "nixos" ]]; then
        echo "  - Run 'nixos-rebuild switch --flake $FLAKE_DIR#<host>' to apply changes"
    else
        echo "  - Run 'home-manager switch --flake $FLAKE_DIR#<profile>' to apply changes"
    fi
}

# Run main function
main "$@"