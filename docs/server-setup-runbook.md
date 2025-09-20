# NixOS Server Setup Runbook

This runbook documents the process for setting up a new NixOS server from a fresh minimal ISO installation.

## Prerequisites

- NixOS minimal ISO (not graphical)
- Target server with network access
- Knowledge of the target hostname (aerith, barrett, rinoa, vincent)

## Initial Setup Steps

### 1. Boot from NixOS ISO

Boot the server from the NixOS minimal installation ISO.

### 2. Set Root Password

The ISO boots with no root password. Set a temporary one for the installation:

```bash
sudo -i
passwd
# Enter a temporary password (will not persist after installation)
```

### 3. Enable SSH Access (Optional but Recommended)

If you want to complete the installation remotely:

```bash
# Start SSH service
systemctl start sshd

# Check your IP address
ip addr show
# Note the IP address for SSH access
```

### 6. Run Bootstrap Script

Now run the bootstrap script which will handle disk partitioning and NixOS installation:

```bash
# Download and run bootstrap
curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
```

### 7. Bootstrap Process

The bootstrap script will:

1. **Detect LiveCD environment** - Confirms you're installing fresh
2. **Ask for system type** - Select "2" for Server
3. **Select server configuration**:
   - aerith (Plex media server)
   - barrett (VPN torrent server)
   - rinoa (General purpose)
   - vincent (CI/CD runner host)
4. **Disk selection** - Enter target disk (e.g., `/dev/sda`, `/dev/vda`, `/dev/nvme0n1`)
5. **Partition and format** - Will erase the entire disk
6. **Hardware detection** - Generates hardware-configuration.nix
7. **SOPS age key** - Enter existing key or skip (can configure later)
8. **Install NixOS** - Applies the selected configuration

### 8. Post-Installation

After the bootstrap completes:

```bash
# Reboot into the new system
reboot
```

### 9. First Boot Configuration

After rebooting into the installed system:

```bash
# Set user password (danny is the default user)
passwd danny

# The system should already have:
# - SSH enabled
# - Network configured
# - Base packages installed
# - Git repository at ~/git/dotfiles-nix

# Future configuration changes:
cd ~/git/dotfiles-nix
sudo nixos-rebuild switch --flake .#<hostname>
```

## Server-Specific Notes

### All Servers
- Run on stable NixOS (25.05)
- Have SSH enabled by default
- User: danny (needs password set on first boot)
- Repository location: `/home/danny/git/dotfiles-nix`

### aerith (Plex Server)
- Plex web UI: http://<server-ip>:32400/web
- Uses unstable plex package via overlay
- Mounts: Configured for media storage

### barrett (VPN Torrent)
- qBittorrent web UI: http://<server-ip>:8080
- Default credentials: admin/changeme (change immediately)
- Requires NordVPN token in SOPS
- Mount: `/mnt/titan` for downloads

### rinoa (General Purpose)
- Docker enabled
- Ready for containerized services

### vincent (CI/CD)
- Docker enabled
- Configured for GitHub/Forgejo runners
- Requires runner tokens in SOPS

## Troubleshooting

### Network Issues
```bash
# Check network interfaces
ip link show

# Restart networking
systemctl restart network-manager
# or
dhcpcd
```

### Bootstrap Fails
```bash
# Clone manually and run from local
git clone https://github.com/nightconcept/dotfiles-nix
cd dotfiles-nix
sudo nixos-install --flake .#<hostname>
```

### SOPS/Age Keys
If you skipped age key setup during bootstrap:
```bash
# Generate new key
age-keygen -o ~/.config/sops/age/keys.txt

# Get public key for .sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt

# Add public key to .sops.yaml in the repository
```

### Disk Detection Issues
```bash
# List all disks
lsblk

# Common disk names:
# SATA/SAS: /dev/sda, /dev/sdb
# NVMe: /dev/nvme0n1, /dev/nvme1n1
# Virtual: /dev/vda, /dev/vdb
```

## Quick Reference

### One-liner for experienced users
```bash
# From NixOS ISO as root:
nix-env -iA nixos.git nixos.curl && \
curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash
```

### Manual disk setup (if bootstrap partition fails)
```bash
# Partition
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary ext4 512MiB 100%

# Format
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mount
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# Generate config
nixos-generate-config --root /mnt
```

## Security Considerations

1. **Change default passwords immediately** after first boot
2. **Configure SOPS/age keys** for secret management
3. **Review firewall rules** in host configurations
4. **Set up proper SSH keys** and disable password auth when ready
5. **Configure fail2ban** if exposed to internet

## Maintenance

### Regular Updates
```bash
cd ~/git/dotfiles-nix
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
```

### Garbage Collection
```bash
# Remove old generations
sudo nix-collect-garbage -d

# Keep last 7 days
sudo nix-collect-garbage --delete-older-than 7d
```