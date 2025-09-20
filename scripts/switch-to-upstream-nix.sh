#!/bin/bash

# Script to switch from Lix to upstream Nix on macOS
# This handles the fact that we're already managed by nix-darwin

set -e

echo "🔄 Switching from Lix to upstream Nix on macOS..."
echo "⚠️  This will require sudo access and a reboot"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup file if it exists
backup_file() {
    if [ -f "$1" ]; then
        echo "📁 Backing up $1"
        sudo cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
    fi
}

echo "1️⃣ Stopping nix-darwin and Nix daemon services..."

# Stop nix-darwin services if they exist
if sudo launchctl list | grep -q org.nixos.nix-daemon; then
    echo "   Stopping nix-daemon..."
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
fi

if sudo launchctl list | grep -q org.nixos.darwin-store; then
    echo "   Stopping darwin-store..."
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || true
fi

echo ""
echo "2️⃣ Shell configuration files are managed by nix-darwin, skipping manual cleanup..."

echo ""
echo "3️⃣ Removing nixbld users and group..."

# Remove nixbld group and users
if dscl . -read /Groups/nixbld >/dev/null 2>&1; then
    echo "   Removing nixbld group..."
    sudo dscl . -delete /Groups/nixbld 2>/dev/null || true
fi

# Remove _nixbld users
for u in $(sudo dscl . -list /Users 2>/dev/null | grep _nixbld || true); do
    echo "   Removing user $u..."
    sudo dscl . -delete /Users/$u 2>/dev/null || true
done

echo ""
echo "4️⃣ Cleaning filesystem configuration..."

# Clean /etc/synthetic.conf
if [ -f /etc/synthetic.conf ]; then
    backup_file "/etc/synthetic.conf"
    if grep -q "^nix" /etc/synthetic.conf 2>/dev/null; then
        echo "   Removing nix from /etc/synthetic.conf..."
        sudo sed -i.bak '/^nix/d' /etc/synthetic.conf
        # Remove file if it's now empty
        if [ ! -s /etc/synthetic.conf ]; then
            sudo rm /etc/synthetic.conf
        fi
    fi
fi

# Clean /etc/fstab
if [ -f /etc/fstab ]; then
    backup_file "/etc/fstab"
    if grep -q "/nix" /etc/fstab 2>/dev/null; then
        echo "   Removing /nix mount from /etc/fstab..."
        sudo sed -i.bak '/\/nix/d' /etc/fstab
    fi
fi

echo ""
echo "5️⃣ Removing Nix files and directories..."

# Remove Nix configuration and profile files
sudo rm -rf /etc/nix 2>/dev/null || true
sudo rm -rf /var/root/.nix-profile 2>/dev/null || true
sudo rm -rf /var/root/.nix-defexpr 2>/dev/null || true
sudo rm -rf /var/root/.nix-channels 2>/dev/null || true
rm -rf ~/.nix-profile 2>/dev/null || true
rm -rf ~/.nix-defexpr 2>/dev/null || true
rm -rf ~/.nix-channels 2>/dev/null || true

# Remove LaunchDaemon plists
sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
sudo rm -f /Library/LaunchDaemons/org.nixos.darwin-store.plist 2>/dev/null || true

echo ""
echo "6️⃣ Force unmounting and removing Nix Store volume..."

# Force kill all processes using /nix
echo "   Killing all processes using /nix..."
sudo pkill -f /nix 2>/dev/null || true

# Use timeout for lsof to prevent hanging
echo "   Finding and killing processes holding /nix (with timeout)..."
timeout 10s sudo lsof +D /nix 2>/dev/null | awk 'NR>1 {print $2}' | sort -u | xargs -r sudo kill -9 2>/dev/null || true

# Additional aggressive cleanup
sudo pkill -9 -f nix-daemon 2>/dev/null || true
sudo pkill -9 -f nix-store 2>/dev/null || true
sudo pkill -9 -f lix 2>/dev/null || true

# Force unmount /nix if mounted
if mount | grep -q "/nix"; then
    echo "   Force unmounting /nix..."
    sudo umount -f /nix 2>/dev/null || true
fi

# Check if Nix Store volume exists and remove it
if diskutil list | grep -q "Nix Store"; then
    echo "   Removing Nix Store volume..."
    NIX_VOLUME=$(diskutil list | grep "Nix Store" | awk '{print $NF}')
    if [ -n "$NIX_VOLUME" ]; then
        sudo diskutil unmount force "$NIX_VOLUME" 2>/dev/null || true
        sudo diskutil apfs deleteVolume "$NIX_VOLUME" 2>/dev/null || {
            echo "   ⚠️  Still couldn't remove volume, continuing anyway..."
        }
    fi
else
    echo "   No Nix Store volume found to remove"
fi

# Remove /nix directory if it exists
if [ -d /nix ]; then
    echo "   Removing /nix directory..."
    sudo rm -rf /nix 2>/dev/null || true
fi

echo ""
echo "6.5️⃣ Ensuring /etc is writable and ready..."

# Make sure /etc exists and is writable
if [ ! -d /etc ]; then
    echo "   Creating /etc directory..."
    sudo mkdir -p /etc
fi

# Remove any broken symlinks in /etc that might interfere
sudo find /etc -type l -exec test ! -e {} \; -delete 2>/dev/null || true

# Ensure bashrc and zshrc don't exist as broken symlinks
for file in bashrc zshrc; do
    if [ -L "/etc/$file" ] && [ ! -e "/etc/$file" ]; then
        echo "   Removing broken symlink /etc/$file"
        sudo rm -f "/etc/$file"
    fi
done

# Create stub files if they don't exist
sudo touch /etc/bashrc 2>/dev/null || true
sudo touch /etc/zshrc 2>/dev/null || true

echo ""
echo "7️⃣ Installing upstream Nix..."

# Install upstream Nix (multi-user)
echo "   Downloading and running official Nix installer..."
echo "   ⚠️  When prompted, say NO to Determinate Systems installer"
sh <(curl -L https://nixos.org/nix/install) --daemon

echo ""
echo "8️⃣ Setting up environment for new shell..."

# Source Nix for current session
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo ""
echo "9️⃣ Reinstalling nix-darwin..."

# Change to the dotfiles directory
cd "$(dirname "$0")/.." || cd ~/git/dotfiles-nix

# Install nix-darwin with the flake
echo "   Running nix-darwin installation..."
nix run nix-darwin -- switch --flake .#waver

echo ""
echo "✅ Switch to upstream Nix completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Restart your terminal or run: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
echo "   2. Verify installation: nix --version"
echo "   3. Test nix-darwin: darwin-rebuild switch --flake .#waver"
echo "   4. Consider rebooting to ensure all changes take effect"
echo ""
echo "🔍 The empty /nix directory will disappear after reboot (this is normal)"
