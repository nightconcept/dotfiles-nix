# Tidus Configurations

This repository now contains two configurations for the Dell Latitude 7420 laptop:

## 1. `tidus` - Standard Configuration

The original configuration without impermanence. This is what you're currently running.

- **Location**: `/hosts/nixos/tidus/`
- **Features**: Standard NixOS with persistent filesystem
- **Use case**: Daily driver, current system
- **To rebuild**: `sudo nixos-rebuild switch --flake .#tidus`

## 2. `tidus-persist` - Impermanence Configuration

New configuration with ephemeral root filesystem.

- **Location**: `/hosts/nixos/tidus-persist/`
- **Features**:
  - LUKS encrypted BTRFS
  - Root wiped on every boot
  - Explicit persistence in `/persist`
  - Recovery tools included
- **Use case**: High-security, stateless computing
- **To install**: Use custom ISO or disko

## Switching Between Configurations

### Current System (tidus)

You can continue using your current system normally:

```bash
# Regular updates
cd ~/git/dotfiles-nix
git pull
sudo nixos-rebuild switch --flake .#tidus
```

### Testing Impermanence (tidus-persist)

To try the impermanence setup:

1. **Build the installer ISO**:
```bash
./scripts/build-tidus-persist-iso.sh
```

2. **Install on separate drive or partition**:
- Boot from ISO
- Run `install-tidus-persist`
- Follow prompts

3. **Or install in VM first**:
```bash
# Test in QEMU
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -drive file=test.img,format=raw,size=20G \
  -cdrom result/iso/tidus-persist-installer.iso
```

## Key Differences

| Feature | tidus | tidus-persist |
|---------|-------|---------------|
| Root persistence | Yes | No (wiped on boot) |
| Disk encryption | Optional | Required (LUKS) |
| Filesystem | BTRFS | BTRFS with subvolumes |
| State management | Traditional | Explicit `/persist` |
| Recovery complexity | Simple | Requires understanding |
| Security | Standard | Enhanced (no persistence) |

## Which Should You Use?

### Use `tidus` if:
- You want a traditional NixOS experience
- You need compatibility with all applications
- You're not ready for the impermanence learning curve
- This is your primary work machine

### Use `tidus-persist` if:
- You want maximum security
- You're comfortable with explicit state management
- You want a clean system every boot
- You're willing to configure persistence for new apps

## Migration Path

The configurations are independent, so you can:

1. Keep using `tidus` as your daily driver
2. Test `tidus-persist` on a spare drive or VM
3. Migrate when comfortable
4. Keep both and dual-boot if desired

## File Structure

```
hosts/nixos/
├── tidus/                      # Current system
│   ├── default.nix            # Main configuration
│   └── hardware-configuration.nix
│
└── tidus-persist/              # Impermanence variant
    ├── default.nix            # Main configuration
    ├── hardware-configuration.nix
    ├── disko.nix              # Disk layout
    ├── impermanence.nix       # Persistence rules
    ├── recovery.nix           # Recovery tools
    └── README.md              # Detailed docs
```

## Commands Quick Reference

```bash
# Current system
sudo nixos-rebuild switch --flake .#tidus

# Build impermanence ISO
./scripts/build-tidus-persist-iso.sh

# Install impermanence (from ISO)
install-tidus-persist

# Check which config you're running
hostname  # Shows 'tidus' or 'tidus-persist'
```