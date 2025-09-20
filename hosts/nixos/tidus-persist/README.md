# Tidus-Persist - NixOS with Impermanence

This configuration sets up NixOS with impermanence using BTRFS, LUKS encryption, and disko for declarative partitioning.

## Features

- **Ephemeral root filesystem**: Root gets wiped on every reboot
- **LUKS encryption**: Full disk encryption for security
- **BTRFS with compression**: Space-efficient storage with snapshots
- **Declarative partitioning**: Reproducible disk layout with disko
- **Selective persistence**: Only specified data survives reboots

## Installation

### Quick Install from ISO

1. Build the custom installer ISO:
```bash
nix build .#nixosConfigurations.tidus-persist-installer.config.system.build.isoImage
# ISO will be in ./result/iso/
```

2. Write ISO to USB drive:
```bash
sudo dd if=./result/iso/tidus-persist-nixos-installer.iso of=/dev/sdX bs=4M status=progress
```

3. Boot from USB and run:
```bash
install-tidus-persist
```

### Manual Installation

1. Boot from any NixOS installer
2. Run disko to partition:
```bash
nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake github:nightconcept/dotfiles-nix#tidus-persist \
  --arg device '"/dev/nvme0n1"'
```

3. Install NixOS:
```bash
nixos-install --flake github:nightconcept/dotfiles-nix#tidus-persist
```

## Post-Installation

### First Boot

On first boot, the system will:
1. Mount the encrypted disk (you'll need to enter your password)
2. Create a blank snapshot of the empty root filesystem
3. Boot normally

### Setting Up Persistence

Check what needs to be persisted:
```bash
# See what's in root that might need persistence
find / -xdev -type f -o -type d | grep -v -E "^/(nix|persist|home|boot)"

# Check persist usage
tidus-persist-persist-check
```

Add needed paths to `/hosts/nixos/tidus-persist/impermanence.nix`.

### Recovery Options

#### Skip Rollback Once
```bash
# For current session
touch /persist-once

# Or at boot: Select "NixOS - Skip Root Rollback" from boot menu
```

#### Recovery Tools
```bash
# Interactive recovery menu
tidus-persist-recovery

# Check persist usage and compression
tidus-persist-persist-check

# Backup critical data
tidus-persist-backup
```

#### Emergency Recovery

If system won't boot:

1. Boot from installer/live USB
2. Decrypt and mount:
```bash
cryptsetup open /dev/nvme0n1p2 cryptroot
mount -o subvol=root /dev/mapper/cryptroot /mnt
mount -o subvol=nix /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist /dev/mapper/cryptroot /mnt/persist
mount /dev/nvme0n1p1 /mnt/boot
nixos-enter
```

3. Fix issues and rebuild:
```bash
# Inside chroot
touch /persist-once  # Skip rollback on next boot
nixos-rebuild switch
```

## Understanding the Layout

### Disk Structure
```
/dev/nvme0n1
├── p1: /boot (512MB, FAT32, unencrypted)
└── p2: LUKS encrypted container
    └── BTRFS filesystem
        ├── @root        → / (ephemeral, wiped on boot)
        ├── @root-blank  → (snapshot template for rollback)
        ├── @nix         → /nix (persistent, system state)
        ├── @persist     → /persist (persistent, explicit data)
        ├── @home        → /home (persistent, user data)
        └── @swap        → /.swapvol (swap file for hibernation)
```

### What Persists

- `/nix` - NixOS system and packages
- `/persist` - Explicitly persisted system state
- `/home` - User home directories
- `/boot` - Boot partition

### What Gets Wiped

Everything else in `/` including:
- `/tmp`, `/var/tmp` - Temporary files
- `/root` - Root user's home
- System logs (unless persisted)
- Any files created outside persisted paths

## Customization

### Add Persistence

Edit `impermanence.nix` to add paths:
```nix
environment.persistence."/persist" = {
  directories = [
    "/var/lib/new-service"
    { directory = "/etc/new-config"; user = "root"; mode = "0700"; }
  ];
  files = [
    "/etc/new-file"
  ];
};
```

### Change Encryption

To add FIDO2/YubiKey support:
```bash
# After installation, enroll key:
sudo systemd-cryptenroll /dev/nvme0n1p2 --fido2-device=auto

# Update disko.nix settings:
settings.crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];
```

### Adjust Swap Size

Edit `disko.nix`:
```nix
"/swap" = {
  mountpoint = "/.swapvol";
  swap.swapfile.size = "32G";  # Adjust size
};
```

## Troubleshooting

### System Won't Boot
- Try "Skip Root Rollback" boot option
- Boot from installer and check logs
- Use emergency recovery procedure

### Out of Space
```bash
# Check BTRFS usage
btrfs filesystem df /
btrfs filesystem usage /

# Clean up old generations
nix-collect-garbage -d
```

### Rollback Issues
```bash
# Check subvolumes
btrfs subvolume list /

# Manually create blank snapshot
mount -o subvol=/ /dev/mapper/cryptroot /mnt
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank-backup
```

## Benefits

1. **Security**: Malware/changes don't persist
2. **Predictability**: Known state on every boot
3. **Cleanliness**: No configuration drift
4. **Debuggability**: Easy to trace what persists

## Caveats

1. **Explicit persistence required**: Must declare what to keep
2. **Initial setup complexity**: More complex than standard install
3. **Application compatibility**: Some apps expect persistent `/var`
4. **Learning curve**: Different mental model

## Resources

- [Impermanence Module](https://github.com/nix-community/impermanence)
- [Disko](https://github.com/nix-community/disko)
- [Erase Your Darlings](https://grahamc.com/blog/erase-your-darlings)