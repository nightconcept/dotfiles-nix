# Migrating Tidus to Tidus-Persist (Impermanence)

This guide covers migrating your existing Tidus system to the new tidus-persist configuration with impermanence, BTRFS, and LUKS encryption.

**Note:** The original `tidus` configuration remains unchanged and can still be used for normal installs without impermanence.

## ⚠️ WARNING

**This process will COMPLETELY WIPE your disk!** Make sure to backup all important data before proceeding.

## Pre-Migration Checklist

### 1. Backup Critical Data

```bash
# Create a backup directory on external drive
mkdir -p /mnt/backup/tidus-$(date +%Y%m%d)

# Backup home directory essentials
rsync -av --progress \
  ~/Documents \
  ~/Pictures \
  ~/Videos \
  ~/Music \
  ~/git \
  ~/.ssh \
  ~/.gnupg \
  /mnt/backup/tidus-$(date +%Y%m%d)/

# Backup browser profiles
cp -r ~/.mozilla /mnt/backup/tidus-$(date +%Y%m%d)/
cp -r ~/.config/google-chrome /mnt/backup/tidus-$(date +%Y%m%d)/

# Export installed packages list (for reference)
nix-env -qa --installed > /mnt/backup/tidus-$(date +%Y%m%d)/installed-packages.txt

# Save network connections
sudo cp -r /etc/NetworkManager/system-connections /mnt/backup/tidus-$(date +%Y%m%d)/
```

### 2. Document Current Setup

```bash
# Save current configuration for reference
cp -r /etc/nixos /mnt/backup/tidus-$(date +%Y%m%d)/

# Document partition layout
lsblk > /mnt/backup/tidus-$(date +%Y%m%d)/disk-layout.txt
df -h > /mnt/backup/tidus-$(date +%Y%m%d)/disk-usage.txt

# Save any custom scripts or configs
find /etc -type f -newer /etc/nixos -exec cp --parents {} /mnt/backup/tidus-$(date +%Y%m%d)/ \;
```

### 3. Check What Needs Persistence

Review what's currently in your system that might need to be persisted:

```bash
# Check /var for important data
du -sh /var/* | sort -hr | head -20

# Check home for dot directories
ls -la ~ | grep "^\."

# Check for Docker/Podman volumes
docker volume ls
podman volume ls
```

## Migration Process

### Option A: Using Custom ISO (Recommended)

1. **Build the installer ISO** (on another machine or current system):
```bash
cd ~/git/dotfiles-nix
git checkout feat/tidus-impermanence
./scripts/build-tidus-persist-iso.sh
```

2. **Create bootable USB**:
```bash
# Find USB device
lsblk

# Write ISO (replace sdX with your USB device)
sudo dd if=result/iso/tidus-persist-installer.iso of=/dev/sdX bs=4M status=progress sync
```

3. **Boot from USB** and run installer:
```bash
# Connect to WiFi if needed
nmtui

# Run automated installer
install-tidus-persist
```

### Option B: Manual Installation

1. **Boot from standard NixOS installer**

2. **Clone the configuration**:
```bash
git clone https://github.com/nightconcept/dotfiles-nix.git /tmp/dotfiles-nix
cd /tmp/dotfiles-nix
git checkout feat/tidus-impermanence
```

3. **Run disko to partition**:
```bash
# Set your disk device
DISK="/dev/nvme0n1"  # Adjust if different

# Run disko (you'll be prompted for encryption password)
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake .#tidus-persist \
  --arg device "\"$DISK\""
```

4. **Install NixOS**:
```bash
sudo nixos-install --flake .#tidus-persist
```

## Post-Installation

### 1. First Boot Setup

After first boot, the system will have an empty root. You'll need to:

1. **Set user password**:
```bash
passwd danny
```

2. **Restore SSH keys** (if needed for git):
```bash
# Copy from backup
cp -r /mnt/backup/tidus-*/home/danny/.ssh /persist/home/danny/
chown -R danny:users /persist/home/danny/.ssh
chmod 700 /persist/home/danny/.ssh
chmod 600 /persist/home/danny/.ssh/*
```

3. **Restore critical configs**:
```bash
# NetworkManager connections
sudo cp -r /mnt/backup/tidus-*/system-connections/* /persist/etc/NetworkManager/system-connections/
sudo chmod 600 /persist/etc/NetworkManager/system-connections/*

# Git config
cp /mnt/backup/tidus-*/.gitconfig /persist/home/danny/
```

### 2. Verify Impermanence

Test that impermanence is working:

```bash
# Create a test file in root
sudo touch /test-file

# Reboot
sudo reboot

# After reboot, check if file is gone
ls /test-file  # Should not exist

# Check persist is working
ls /persist/home/danny  # Should have your data
```

### 3. Restore User Data

```bash
# Restore documents and projects
rsync -av /mnt/backup/tidus-*/Documents/ ~/Documents/
rsync -av /mnt/backup/tidus-*/git/ ~/git/

# Restore browser profiles
cp -r /mnt/backup/tidus-*/.mozilla ~/
cp -r /mnt/backup/tidus-*/.config/google-chrome ~/.config/
```

### 4. Fine-tune Persistence

After using the system for a few days, check what else needs persisting:

```bash
# Check what's been created in root
find / -xdev -type f -newer /persist -ls 2>/dev/null

# Check persist usage
tidus-persist-check

# Add needed paths to impermanence.nix
```

## Rollback Plan

If something goes wrong and you need to go back:

1. **Keep old drive/backup** for at least a week
2. **Document issues** you encounter
3. **Emergency recovery**:
   - Boot from installer
   - Mount old backup
   - Restore old partition layout
   - Reinstall standard NixOS

## Troubleshooting

### System Won't Boot
- Try "Skip Root Rollback" from boot menu
- Boot installer and check logs:
  ```bash
  journalctl -b -p err
  ```

### Missing Data After Reboot
- Check if path is in impermanence.nix
- Add to persistence configuration:
  ```bash
  vi /persist/home/danny/git/dotfiles-nix/hosts/nixos/tidus/impermanence.nix
  # Add missing paths
  cd /persist/home/danny/git/dotfiles-nix
  sudo nixos-rebuild switch --flake .#tidus-persist
  ```

### Performance Issues
- Check BTRFS compression ratio:
  ```bash
  compsize /
  compsize /persist
  ```
- Monitor disk I/O:
  ```bash
  iotop -o
  ```

## Benefits After Migration

1. **Clean System**: No configuration drift
2. **Security**: Malware can't persist
3. **Predictability**: Known state every boot
4. **Easy Recovery**: Just reboot to fix most issues
5. **Explicit State**: You know exactly what persists

## Need Help?

- Check the [README](hosts/nixos/tidus/README.md) for detailed usage
- Review recovery options with `tidus-recovery`
- Keep backups until comfortable with the new setup