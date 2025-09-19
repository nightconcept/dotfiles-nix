#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== NixOS Server Installation Script ===${NC}"
echo -e "${YELLOW}This script installs NixOS with a standard server configuration${NC}"
echo -e "${YELLOW}Run this from a NixOS LiveCD/ISO${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use 'sudo -i' on LiveCD)${NC}"
    exit 1
fi

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local value
    read -p "$prompt [$default]: " value
    echo "${value:-$default}"
}

# Gather configuration
HOSTNAME=$(prompt_with_default "Enter hostname" "server")
USERNAME=$(prompt_with_default "Enter primary username" "danny")
DISK=$(prompt_with_default "Enter target disk (e.g., /dev/sda, /dev/vda)" "/dev/sda")

# AGE key setup for SOPS secrets
echo -e "\n${YELLOW}SOPS Secret Management Setup${NC}"
echo -e "${BLUE}An AGE key is required to decrypt secrets (SSH keys, API tokens, etc.)${NC}"
read -p "Do you have an AGE private key for SOPS? (yes/no): " has_age_key

if [ "$has_age_key" = "yes" ]; then
    echo -e "${YELLOW}Paste your AGE private key (starts with AGE-SECRET-KEY-), then press Ctrl+D:${NC}"
    AGE_KEY=$(cat)
    echo -e "${GREEN}AGE key received${NC}"
else
    echo -e "${YELLOW}Generating new AGE key pair...${NC}"
    # We'll need age installed
    nix-shell -p age --run "age-keygen -o /tmp/age.key" 2>/dev/null
    AGE_KEY=$(cat /tmp/age.key | grep "^AGE-SECRET-KEY")
    AGE_PUBLIC=$(cat /tmp/age.key | grep "^# public key:" | cut -d' ' -f4)
    
    echo -e "${GREEN}Generated new AGE key pair${NC}"
    echo -e "${RED}IMPORTANT: Save this information!${NC}"
    echo -e "${YELLOW}Public key:${NC} $AGE_PUBLIC"
    echo -e "${YELLOW}Private key:${NC} $AGE_KEY"
    echo -e "${RED}You'll need to add the public key to .sops.yaml and re-encrypt secrets${NC}"
    rm /tmp/age.key
fi

# Confirm disk selection
echo -e "\n${YELLOW}WARNING: This will completely erase ${DISK}${NC}"
lsblk "$DISK" 2>/dev/null || { echo -e "${RED}Disk $DISK not found${NC}"; exit 1; }
read -p "Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted"
    exit 1
fi

echo -e "\n${GREEN}Partitioning disk...${NC}"

# Wipe disk
wipefs -af "$DISK"
sgdisk -Z "$DISK"

# Create partitions
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary ext4 512MiB 100%

# Wait for kernel to recognize partitions
sleep 2

# Determine partition naming scheme
if [ -b "${DISK}p1" ]; then
    BOOT_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
else
    BOOT_PART="${DISK}1"
    ROOT_PART="${DISK}2"
fi

echo -e "${GREEN}Formatting partitions...${NC}"

# Format partitions
mkfs.fat -F32 -n boot "$BOOT_PART"
mkfs.ext4 -L nixos "$ROOT_PART"

echo -e "${GREEN}Mounting filesystems...${NC}"

# Mount filesystems
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

echo -e "${GREEN}Generating hardware configuration...${NC}"

# Generate NixOS hardware configuration
nixos-generate-config --root /mnt

echo -e "${GREEN}Cloning dotfiles repository...${NC}"

# Clone the repository (git should be available on NixOS LiveCD)
git clone https://github.com/nightconcept/dotfiles-nix.git /mnt/etc/nixos/dotfiles-nix

cd /mnt/etc/nixos/dotfiles-nix

# Setup AGE key for SOPS regardless of host config
if [ -n "$AGE_KEY" ]; then
    mkdir -p "/mnt/var/lib/sops-nix"
    echo "$AGE_KEY" > "/mnt/var/lib/sops-nix/key.txt"
    chmod 600 "/mnt/var/lib/sops-nix/key.txt"
    echo -e "${GREEN}AGE key installed for SOPS${NC}"
fi

# Check if host configuration already exists
if [ -d "hosts/nixos/$HOSTNAME" ]; then
    echo -e "${BLUE}Using existing host configuration for $HOSTNAME${NC}"
    # Update the hardware configuration with the newly generated one
    cp /mnt/etc/nixos/hardware-configuration.nix "hosts/nixos/$HOSTNAME/"
else
    echo -e "${YELLOW}Creating new host configuration for $HOSTNAME${NC}"
    
    # Create host directory
    mkdir -p "hosts/nixos/$HOSTNAME"
    
    # Use the nixos-generate-config output
    cp /mnt/etc/nixos/hardware-configuration.nix "hosts/nixos/$HOSTNAME/"
    
    
    # Create host configuration based on barrett template
    cat > "hosts/nixos/$HOSTNAME/default.nix" << EOF
{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = {
    nixos = {
      core = {
        enable = true;
        hostname = "$HOSTNAME";
        username = "$USERNAME";
        timezone = "America/Los_Angeles";
      };

      networking = {
        enable = true;
        useDHCP = true;
      };

      ssh = {
        enable = true;
        allowPasswordAuth = true;  # Initially allow password auth for setup
      };

      security = {
        sops.enable = true;
      };
    };
  };

  system.stateVersion = "24.05";
}
EOF

    # Add to home configuration
    if ! grep -q "$HOSTNAME = {" home/default.nix; then
        echo -e "${YELLOW}Adding $HOSTNAME to home configuration...${NC}"
        
        # Find the line with "# Darwin hosts" and insert before it
        sed -i "/# Darwin hosts/i\\    $HOSTNAME = {\\n      profiles = [ ./profiles/server.nix ];\\n      homeDirectory = \"/home/$USERNAME\";\\n      extraImports = [ ];\\n      extraConfig = {};\\n    };\\n    " home/default.nix
    fi
    
    # Add to flake.nix if not present
    if ! grep -q "$HOSTNAME = lib.mkNixosServer" flake.nix; then
        echo -e "${YELLOW}Adding $HOSTNAME to flake.nix...${NC}"
        
        # Add after the last mkNixosServer line
        sed -i "/barrett = lib.mkNixosServer/a\\      $HOSTNAME = lib.mkNixosServer inputs.nixpkgs \"$HOSTNAME\";" flake.nix
    fi
fi

echo -e "${GREEN}Installing NixOS...${NC}"
echo -e "${YELLOW}This may take a while...${NC}"

# Install NixOS
nixos-install --flake ".#$HOSTNAME" --no-root-password

echo -e "\n${GREEN}✓ Installation complete!${NC}"
echo -e "${BLUE}System Information:${NC}"
echo "Hostname: ${YELLOW}$HOSTNAME${NC}"
echo "Username: ${YELLOW}$USERNAME${NC}"

echo -e "\n${BLUE}Next steps:${NC}"
echo "1. Reboot: ${YELLOW}reboot${NC}"
echo "2. SSH into the system: ${YELLOW}ssh $USERNAME@<server-ip>${NC}"
echo "3. Set user password: ${YELLOW}passwd${NC}"

if [ "$has_age_key" = "yes" ]; then
    echo "4. Your SSH keys should be available at ~/.ssh/id_sdev (from SOPS)"
    echo "5. Disable password auth in the host config and rebuild"
else
    echo "4. Add the AGE public key to .sops.yaml in the dotfiles repo"
    echo "5. Re-encrypt secrets with: ${YELLOW}sops updatekeys modules/nixos/security/sops/common.yaml${NC}"
    echo "6. Push changes and rebuild to get SSH keys from SOPS"
fi

echo -e "\n${YELLOW}Dotfiles location:${NC} /etc/nixos/dotfiles-nix"
echo -e "${YELLOW}Rebuild command:${NC} sudo nixos-rebuild switch --flake /etc/nixos/dotfiles-nix#$HOSTNAME"

if [ "$HOSTNAME" = "rinoa" ] || grep -q "docker" "hosts/nixos/$HOSTNAME/default.nix" 2>/dev/null; then
    echo -e "\n${BLUE}Docker is enabled on this host.${NC}"
    echo "You can now deploy docker-compose files from your monorepo."
fi