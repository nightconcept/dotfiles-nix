#!/usr/bin/env bash
#
# Universal Bootstrap Script for Nix Dotfiles
#
# Usage:
#   # From existing system or NixOS LiveCD
#   curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
#   wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
#
#   # Force fresh installation mode (useful when auto-detection fails)
#   curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash -s -- --install
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

# Check if running from NixOS LiveCD/Installer
is_nixos_livecd() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "nixos" ]]; then
            # Check multiple indicators of installer environment:
            # 1. No existing nixos-rebuild command (fresh install)
            # 2. Root filesystem is tmpfs (common for live systems)
            # 3. nixos user exists (typical installer user)
            # 4. No /mnt/etc/nixos/configuration.nix (not installed yet)
            if { ! command -v nixos-rebuild &>/dev/null; } || \
               { mountpoint -q / && findmnt -n -o FSTYPE / | grep -q tmpfs; } || \
               { id nixos &>/dev/null; } || \
               { [[ ! -f /etc/nixos/configuration.nix ]] && [[ ! -L /etc/nixos/configuration.nix ]]; }; then
                return 0
            fi
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
            read -p "Continue anyway? (y/n): " -n 1 -r </dev/tty
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
    print_info "What type of system is this?" >&2
    echo "  1) Desktop/Laptop (with GUI)" >&2
    echo "  2) Server (headless, no GUI)" >&2
    echo >&2

    # Check if /dev/tty is available
    if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
        print_warning "/dev/tty not available, defaulting to server configuration" >&2
        echo "server"
        return
    fi

    read -p "Select type (1-2): " -n 1 -r </dev/tty || {
        print_warning "Failed to read input, defaulting to server configuration" >&2
        echo "server"
        return
    }
    echo >&2

    case "$REPLY" in
        1)
            echo "desktop"
            ;;
        2)
            echo "server"
            ;;
        *)
            print_error "Invalid selection" >&2
            select_system_type
            ;;
    esac
}

# NixOS host selection menu for desktops
select_desktop_host() {
    print_info "Available desktop configurations:" >&2
    echo "  1) tidus   - Dell Latitude 7420 laptop" >&2
    echo "  2) Skip    - Don't switch configuration" >&2
    echo >&2

    if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
        print_warning "/dev/tty not available, skipping configuration" >&2
        echo "skip"
        return
    fi

    read -p "Select configuration (1-2): " -n 1 -r </dev/tty || {
        print_warning "Failed to read input, skipping configuration" >&2
        echo "skip"
        return
    }
    echo >&2

    case "$REPLY" in
        1)
            echo "tidus"
            ;;
        2)
            echo "skip"
            ;;
        *)
            print_error "Invalid selection" >&2
            select_desktop_host
            ;;
    esac
}

# NixOS host selection menu for servers
select_server_host() {
    print_info "Available server configurations:" >&2
    echo "  1) aerith  - Plex media server" >&2
    echo "  2) barrett - VPN torrent server" >&2
    echo "  3) rinoa   - Docker server" >&2
    echo "  4) Skip    - Don't switch configuration" >&2
    echo >&2

    if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
        print_warning "/dev/tty not available, defaulting to rinoa" >&2
        echo "rinoa"
        return
    fi

    read -p "Select configuration (1-4): " -n 1 -r </dev/tty || {
        print_warning "Failed to read input, defaulting to rinoa" >&2
        echo "rinoa"
        return
    }
    echo >&2

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
            print_error "Invalid selection" >&2
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
    
    if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
        print_warning "/dev/tty not available, skipping age key setup"
        return
    fi

    read -p "Select option (1-3): " -n 1 -r </dev/tty || {
        print_warning "Failed to read input, skipping age key setup"
        return
    }
    echo
    
    case "$REPLY" in
        1)
            echo "Enter your age private key (starts with AGE-SECRET-KEY):"
            if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
                print_warning "/dev/tty not available, skipping age key input"
                return 1
            fi
            read -r age_key </dev/tty || return 1
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

    if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
        print_warning "/dev/tty not available, auto-confirming disk erase"
        confirm="yes"
    else
        read -p "Continue? (yes/no): " confirm </dev/tty || confirm="yes"
    fi

    if [ "$confirm" != "yes" ]; then
        echo "Aborted"
        exit 1
    fi

    print_info "Partitioning disk..."

    # Wipe disk
    wipefs -af "$disk"
    sgdisk -Z "$disk"

    # Create partitions for BIOS/MBR boot
    parted "$disk" -- mklabel msdos
    parted "$disk" -- mkpart primary ext4 1MiB 100%
    parted "$disk" -- set 1 boot on

    sleep 2

    # Determine partition naming scheme
    if [ -b "${disk}p1" ]; then
        ROOT_PART="${disk}p1"
    else
        ROOT_PART="${disk}1"
    fi

    print_info "Formatting partition..."
    mkfs.ext4 -L nixos "$ROOT_PART"

    print_info "Mounting filesystem..."
    mount "$ROOT_PART" /mnt

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

    print_info "Root check passed, EUID=$EUID"

    # Determine system type
    print_info "About to select system type..."
    system_type=$(select_system_type)
    print_info "System type selected: $system_type"

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

    # Setup age keys for user-level secrets
    print_info "Setting up SOPS age keys..."
    # Create age directory in mounted system (user-level location)
    mkdir -p /mnt/home/danny/.config/sops/age

    # Check for existing key or prompt for new one
    if [[ -f "$HOME/.config/sops/age/keys.txt" ]]; then
        print_info "Using existing age key"
        cp "$HOME/.config/sops/age/keys.txt" /mnt/home/danny/.config/sops/age/keys.txt
        chmod 600 /mnt/home/danny/.config/sops/age/keys.txt
        chown 1000:100 /mnt/home/danny/.config/sops/age/keys.txt
    else
        print_info "Age key is required for accessing encrypted secrets (SOPS)"
        echo "Enter your age private key (starts with AGE-SECRET-KEY):"
        echo "(Press Enter to skip if you don't have one)"
        if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
            print_warning "/dev/tty not available, skipping age key input"
            age_key=""
        else
            read -r age_key </dev/tty || age_key=""
        fi
        if [[ "$age_key" =~ ^AGE-SECRET-KEY ]]; then
            echo "$age_key" > /mnt/home/danny/.config/sops/age/keys.txt
            chmod 600 /mnt/home/danny/.config/sops/age/keys.txt
            chown 1000:100 /mnt/home/danny/.config/sops/age/keys.txt
            print_success "Age key saved"
        else
            print_warning "No age key provided, secrets won't work until configured"
        fi
    fi

    # Optionally set a password for the user
    print_info "User account setup"
    echo "Set a password for user 'danny' now? (recommended for SSH access)"
    echo "Press Enter to skip and set it after first boot"

    local hashed_password=""
    if [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        read -s -p "Enter password (or press Enter to skip): " user_password </dev/tty
        echo
        if [[ -n "$user_password" ]]; then
            # Hash the password using mkpasswd
            if command -v mkpasswd &>/dev/null; then
                hashed_password=$(mkpasswd -m sha-512 "$user_password")
                print_success "Password set for user danny"
            else
                print_warning "mkpasswd not found, trying openssl"
                # Fallback to openssl if available
                if command -v openssl &>/dev/null; then
                    local salt=$(openssl rand -base64 16 | tr -d '\n')
                    hashed_password=$(openssl passwd -6 -salt "$salt" "$user_password")
                    print_success "Password set for user danny"
                else
                    print_warning "Cannot hash password, will need to set after boot"
                fi
            fi
        fi
    fi

    # Create a minimal configuration that just boots
    print_info "Generating minimal bootable configuration..."
    if [[ -n "$hashed_password" ]]; then
        cat > /mnt/etc/nixos/configuration.nix <<EOF
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      device = "DISK_PLACEHOLDER";  # Install GRUB to MBR
    };
  };

  networking.hostName = "HOSTNAME_PLACEHOLDER";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  users.users.danny = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$hashed_password";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
EOF
    else
        cat > /mnt/etc/nixos/configuration.nix <<'EOF'
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      device = "DISK_PLACEHOLDER";  # Install GRUB to MBR
    };
  };

  networking.hostName = "HOSTNAME_PLACEHOLDER";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  users.users.danny = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
EOF
    fi
    # Replace placeholders
    sed -i "s/HOSTNAME_PLACEHOLDER/$host/g" /mnt/etc/nixos/configuration.nix
    sed -i "s|DISK_PLACEHOLDER|$disk|g" /mnt/etc/nixos/configuration.nix

    # Install minimal system
    print_info "Installing minimal NixOS system..."
    nixos-install --no-root-password

    # Create post-install script
    cat > /mnt/home/danny/apply-full-config.sh <<'EOF'
#!/usr/bin/env bash
echo "Applying full flake configuration..."
cd ~/git/dotfiles-nix
sudo nixos-rebuild switch --flake .#HOSTNAME_PLACEHOLDER
echo "Configuration complete!"
EOF
    sed -i "s/HOSTNAME_PLACEHOLDER/$host/g" /mnt/home/danny/apply-full-config.sh
    chmod +x /mnt/home/danny/apply-full-config.sh
    chown 1000:100 /mnt/home/danny/apply-full-config.sh

    print_success "Installation complete!"
    echo
    echo "Next steps:"
    echo "1. Reboot into your new system: reboot"
    if [[ -z "$hashed_password" ]]; then
        echo "2. Log in as 'danny' (no password required)"
        echo "3. Set your password immediately: passwd"
        echo "4. Apply the full configuration: ~/apply-full-config.sh"
    else
        echo "2. Log in as 'danny' with the password you set"
        echo "3. Apply the full configuration: ~/apply-full-config.sh"
    fi
    echo
    echo "The system is now running a minimal NixOS installation with SSH enabled."
    echo "The full flake configuration will be applied after reboot."
}

# Prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local value

    if [[ ! -r /dev/tty ]] || [[ ! -w /dev/tty ]]; then
        print_warning "/dev/tty not available, using default: $default"
        echo "$default"
        return
    fi

    read -p "$prompt [$default]: " value </dev/tty || {
        print_warning "Failed to read input, using default: $default"
        echo "$default"
        return
    }
    echo "${value:-$default}"
}

# Main installation flow
main() {
    # Parse command-line arguments
    local force_install=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install|--fresh-install)
                force_install=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --install, --fresh-install  Force fresh installation mode"
                echo "  --help, -h                  Show this help message"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done

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
            # Check if running from LiveCD (fresh install) or forced install mode
            if is_nixos_livecd || [[ "$force_install" == "true" ]]; then
                if [[ "$force_install" == "true" ]]; then
                    print_info "Fresh installation mode (forced)"
                else
                    print_info "Detected NixOS installer environment"
                fi
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
    
    # Installation is handled above in nixos_fresh_install for NixOS
    # This section is only reached for non-NixOS systems
    print_success "Bootstrap complete!"
}

# Run main function
main "$@"