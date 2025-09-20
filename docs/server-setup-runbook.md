# NixOS Server Setup Runbook

This runbook documents the process for setting up a new NixOS server from a fresh minimal ISO installation.

## Prerequisites

- NixOS minimal ISO
- Target server with network access
- Knowledge of the target hostname (aerith, barrett, rinoa, vincent)
- (Optional) AGE secret key for SOPS-encrypted secrets

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

### 4. Connect via SSH (if enabled)

```bash
# From another machine
ssh root@<server-ip>
# Enter the password you set in step 2
```

### 5. Verify Network Connectivity

```bash
# Test network access
ping -c 3 github.com
# If no network, configure it first
```

### 6. Run Bootstrap Script

Now run the bootstrap script which will handle disk partitioning and NixOS installation:

```bash
# Option 1: Auto-detect installer environment
curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash

# Option 2: Force installation mode (if auto-detection fails)
curl -sSL https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash -s -- --install

# Alternative using wget:
wget -qO- https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh | bash -s -- --install
```

**Note:** If the script stops immediately after detecting the installer environment, it's likely having issues reading input when piped. Use the `--install` flag to force installation mode.

### 7. Bootstrap Process

The bootstrap script will:

1. **Detect installer environment** - Auto-detects NixOS installer (or use `--install` to force)
2. **Ask for system type** - Select "2" for Server
3. **Select server configuration**:
   - aerith (Plex media server)
   - barrett (VPN torrent server)
   - rinoa (Docker server)
   - vincent (CI/CD runner host)
4. **Disk selection** - Enter target disk (e.g., `/dev/sda`, `/dev/vda`, `/dev/nvme0n1`)
5. **Partition and format** - Will erase the entire disk
6. **Hardware detection** - Generates hardware-configuration.nix
7. **SOPS age key** - Enter existing key or skip (can configure later)
8. **Install minimal system** - Creates a bootable system with network and SSH

### 8. Post-Installation

After the bootstrap completes:

```bash
# Reboot into the new system
reboot
```

### 9. First Boot Configuration

After rebooting into the installed system:

```bash
# Log in as danny (no password set)
# Set user password immediately
passwd

# Apply the full flake configuration
~/apply-full-config.sh

# Future configuration changes:
cd ~/git/dotfiles-nix
sudo nixos-rebuild switch --flake .#<hostname>
```

## Troubleshooting

### Bootstrap Script Issues

**Script stops after "Detected NixOS installer environment":**
- The script may have issues reading input when piped through curl/wget
- Solution: Use the `--install` flag to force installation mode
- Alternative: Download the script first, then run it:
  ```bash
  wget https://raw.githubusercontent.com/nightconcept/dotfiles-nix/main/bootstrap.sh
  chmod +x bootstrap.sh
  sudo ./bootstrap.sh --install
  ```

**"Fresh installation requires root" error:**
- Ensure you're running as root: `sudo -i`
- Then run the bootstrap script

**AGE key issues:**
- You can skip AGE key setup during installation
- Configure it later by placing your key at `~/.config/sops/age/keys.txt`
- Format: `AGE-SECRET-KEY-...`

### Network Issues

**No network connectivity:**
- Check cable connection
- Use `ip addr` to verify network interface is up
- DHCP should work automatically on most networks
- For static IP, configure before running bootstrap


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

### rinoa (Docker Server)
- Docker enabled
- Ready for containerized services
- General purpose Docker host

### vincent (CI/CD)
- Docker enabled
- Configured for GitHub/Forgejo runners
- Requires runner tokens in SOPS
