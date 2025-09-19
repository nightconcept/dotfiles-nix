#!/usr/bin/env bash
#
# Universal Bootstrap Script for Nix Dotfiles
#
# Usage:
#   # From existing system or NixOS LiveCD
#   curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
#   wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
#
# Supports:
#   - NixOS fresh installation (auto-detected from LiveCD)
#   - NixOS existing system (configuration switching)
#   - Linux distros (Ubuntu, Fedora, Arch, SUSE, Alpine, etc.)
#   - macOS (partial - manual steps required)
#
# Features:
#   - Auto-detects if running from LiveCD for fresh install
#   - Partitions disk and installs NixOS when on LiveCD
#   - Switches configuration on existing NixOS systems
#   - Sets up Home Manager on non-NixOS Linux
#   - Handles both desktop and server installations
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

# Check if running from NixOS LiveCD
is_nixos_livecd() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        # NixOS LiveCD typically runs from tmpfs and has no /etc/nixos
        if [[ "$ID" == "nixos" ]] && [[ ! -d /etc/nixos ]] && mountpoint -q /; then
            return 0
        fi
    fi
    return 1
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

# Determine system type
select_system_type() {
    print_info "What type of system is this?"
    echo "  1) Desktop/Laptop (with GUI)"
    echo "  2) Server (headless, no GUI)"
    echo

    read -p "Select type (1-2): " -n 1 -r
    echo

    case "$REPLY" in
        1)
            echo "desktop"
            ;;
        2)
            echo "server"
            ;;
        *)
            print_error "Invalid selection"
            select_system_type
            ;;
    esac
}

# NixOS host selection menu for desktops
select_desktop_host() {
    print_info "Available desktop configurations:"
    echo "  1) tidus   - Dell Latitude 7420 laptop"
    echo "  2) Skip    - Don't switch configuration"
    echo

    read -p "Select configuration (1-2): " -n 1 -r
    echo

    case "$REPLY" in
        1)
            echo "tidus"
            ;;
        2)
            echo "skip"
            ;;
        *)
            print_error "Invalid selection"
            select_desktop_host
            ;;
    esac
}

# NixOS host selection menu for servers
select_server_host() {
    print_info "Available server configurations:"
    echo "  1) aerith  - Plex media server"
    echo "  2) barrett - VPN torrent server"
    echo "  3) rinoa   - Docker server"
    echo "  4) Skip    - Don't switch configuration"
    echo

    read -p "Select configuration (1-4): " -n 1 -r
    echo

    case "$REPLY" in
        1)
            echo "aerith"
            ;;
        2)
            echo "barrett"
            ;;
        3)
            echo "rinoa"
            ;;
        4)
            echo "skip"
            ;;
        *)
            print_error "Invalid selection"
            select_server_host
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
    local is_install=${2:-false}

    print_info "Building and switching to NixOS configuration: $host"

    # Enable flakes if not already enabled
    if ! grep -q "experimental-features.*flakes" /etc/nix/nix.conf 2>/dev/null; then
        echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
    fi

    # Setup age keys before applying config
    setup_age_keys

    # Build and switch
    if [[ "$is_install" == "true" ]]; then
        nixos-install --flake ".#$host" --no-root-password
    else
        sudo nixos-rebuild switch --flake ".#$host"
    fi

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

# Partition and format disk for fresh install
setup_disk() {
    local disk=$1

    print_warning "This will completely erase $disk"
    lsblk "$disk" 2>/dev/null || { print_error "Disk $disk not found"; exit 1; }
    read -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted"
        exit 1
    fi

    print_info "Partitioning disk..."

    # Wipe disk
    wipefs -af "$disk"
    sgdisk -Z "$disk"

    # Create partitions
    parted "$disk" -- mklabel gpt
    parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
    parted "$disk" -- set 1 esp on
    parted "$disk" -- mkpart primary ext4 512MiB 100%

    sleep 2

    # Determine partition naming scheme
    if [ -b "${disk}p1" ]; then
        BOOT_PART="${disk}p1"
        ROOT_PART="${disk}p2"
    else
        BOOT_PART="${disk}1"
        ROOT_PART="${disk}2"
    fi

    print_info "Formatting partitions..."
    mkfs.fat -F32 -n boot "$BOOT_PART"
    mkfs.ext4 -L nixos "$ROOT_PART"

    print_info "Mounting filesystems..."
    mount "$ROOT_PART" /mnt
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot

    print_info "Generating hardware configuration..."
    nixos-generate-config --root /mnt

    # Clone repository to target location
    print_info "Cloning dotfiles repository..."
    mkdir -p /mnt/home/danny/git
    git clone "$FLAKE_REPO" /mnt/home/danny/git/dotfiles-nix

    # Create symlink at /etc/nixos for convenience
    mkdir -p /mnt/etc/nixos
    ln -sf /home/danny/git/dotfiles-nix /mnt/etc/nixos/dotfiles-nix

    # Copy hardware configuration to host directory
    if [[ -n "$ARG_HOSTNAME" ]]; then
        mkdir -p "/mnt/etc/nixos/dotfiles-nix/hosts/nixos/$ARG_HOSTNAME"
        cp /mnt/etc/nixos/hardware-configuration.nix "/mnt/etc/nixos/dotfiles-nix/hosts/nixos/$ARG_HOSTNAME/"
    fi

    print_success "Disk setup complete"
}

# NixOS fresh installation flow
nixos_fresh_install() {
    print_info "Starting NixOS fresh installation from LiveCD"

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_error "Fresh installation requires root. Use 'sudo -i' on LiveCD"
        exit 1
    fi

    # Determine system type
    system_type=$(select_system_type)

    # Select host configuration based on type
    local host
    if [[ "$system_type" == "desktop" ]]; then
        host=$(select_desktop_host)
    else
        host=$(select_server_host)
    fi

    if [[ "$host" == "skip" ]]; then
        print_error "Host configuration required for installation"
        exit 1
    fi

    # Get installation parameters
    local disk=$(prompt_with_default "Enter target disk (e.g., /dev/sda, /dev/vda)" "/dev/sda")

    # Setup disk
    setup_disk "$disk"

    # Change to repository directory
    cd /mnt/home/danny/git/dotfiles-nix

    # Update hardware configuration for the selected host
    print_info "Updating hardware configuration for $host"
    cp /mnt/etc/nixos/hardware-configuration.nix "hosts/nixos/$host/"

    # Setup age keys
    print_info "Setting up SOPS age keys..."
    # Create age directory in mounted system
    mkdir -p /mnt/var/lib/sops-nix

    # Check for existing key or prompt for new one
    if [[ -f "$HOME/.config/sops/age/keys.txt" ]]; then
        print_info "Using existing age key"
        cp "$HOME/.config/sops/age/keys.txt" /mnt/var/lib/sops-nix/key.txt
        chmod 600 /mnt/var/lib/sops-nix/key.txt
    else
        print_info "Age key is required for accessing encrypted secrets (SOPS)"
        echo "Enter your age private key (starts with AGE-SECRET-KEY):"
        echo "(Press Enter to skip if you don't have one)"
        read -r age_key
        if [[ "$age_key" =~ ^AGE-SECRET-KEY ]]; then
            echo "$age_key" > /mnt/var/lib/sops-nix/key.txt
            chmod 600 /mnt/var/lib/sops-nix/key.txt
            print_success "Age key saved"
        else
            print_warning "No age key provided, secrets won't work until configured"
        fi
    fi

    # Install system
    print_info "Installing NixOS with configuration: $host"
    nixos-install --flake ".#$host" --no-root-password

    print_success "Installation complete!"
    echo
    echo "Next steps:"
    echo "1. Reboot: reboot"
    echo "2. Set user password after reboot"
    echo "3. Repository location: ~/git/dotfiles-nix"
    echo "4. Rebuild command: sudo nixos-rebuild switch --flake ~/git/dotfiles-nix#$host"
}

# Prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local value
    read -p "$prompt [$default]: " value
    echo "${value:-$default}"
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
            # Check if running from LiveCD (fresh install)
            if is_nixos_livecd; then
                print_info "Detected NixOS LiveCD environment"
                nixos_fresh_install
            else
                # Existing NixOS system
                print_info "Running on existing NixOS system"
                clone_flake

                # Determine system type and select configuration
                system_type=$(select_system_type)
                local host
                if [[ "$system_type" == "desktop" ]]; then
                    host=$(select_desktop_host)
                else
                    host=$(select_server_host)
                fi

                if [[ "$host" != "skip" ]]; then
                    apply_nixos_config "$host"
                else
                    print_info "Skipping NixOS configuration"
                fi
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