#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
else
    echo "Cannot detect Linux distribution" >&2
    exit 1
fi

# Check for and install cifs-utils based on distro
case "$DISTRO" in
    debian|ubuntu|linuxmint|pop)
        if ! dpkg -s cifs-utils >/dev/null 2>&1; then
            echo "cifs-utils not found, installing..."
            apt-get update && apt-get install -y cifs-utils || {
                echo "Failed to install cifs-utils" >&2
                exit 1
            }
        fi
        ;;
    arch|manjaro|endeavouros|cachyos)
        if ! pacman -Qi cifs-utils >/dev/null 2>&1; then
            echo "cifs-utils not found, installing..."
            
            # Check for stale pacman lock
            if [ -f /var/lib/pacman/db.lck ]; then
                if ! pgrep -x "pacman" >/dev/null && ! pgrep "yay" >/dev/null && ! pgrep "paru" >/dev/null; then
                    echo "Removing stale pacman lock file..."
                    rm -f /var/lib/pacman/db.lck
                else
                    echo "Another package manager is running. Please wait for it to finish." >&2
                    exit 1
                fi
            fi
            
            pacman -S --noconfirm cifs-utils || {
                echo "Failed to install cifs-utils" >&2
                echo "Please run manually: sudo pacman -S cifs-utils" >&2
                exit 1
            }
        else
            echo "cifs-utils is already installed"
        fi
        ;;
    fedora|rhel|centos|rocky|almalinux)
        if ! rpm -q cifs-utils >/dev/null 2>&1; then
            echo "cifs-utils not found, installing..."
            dnf install -y cifs-utils || yum install -y cifs-utils || {
                echo "Failed to install cifs-utils" >&2
                exit 1
            }
        fi
        ;;
    opensuse*|suse*)
        if ! rpm -q cifs-utils >/dev/null 2>&1; then
            echo "cifs-utils not found, installing..."
            zypper install -y cifs-utils || {
                echo "Failed to install cifs-utils" >&2
                exit 1
            }
        fi
        ;;
    *)
        echo "Unsupported distribution: $DISTRO" >&2
        echo "Please manually install cifs-utils and try again" >&2
        exit 1
        ;;
esac

# Create mount directory
mkdir -p /mnt/titan

# Handle credentials file
if [ -f /etc/mog-secrets ]; then
    echo "Using existing credentials file at /etc/mog-secrets"
else
    echo "Creating new credentials file"
    cat > /etc/mog-secrets <<EOF
username=danny
domain=mog
password=CHANGEME
EOF
    chmod 600 /etc/mog-secrets
    
    echo "Please edit the credentials file with your actual password"
    read -p "Press enter to continue..."
    # Use available editor
    if command -v nano >/dev/null 2>&1; then
        nano /etc/mog-secrets
    elif command -v vim >/dev/null 2>&1; then
        vim /etc/mog-secrets
    elif command -v vi >/dev/null 2>&1; then
        vi /etc/mog-secrets
    else
        echo "No text editor found. Please manually edit /etc/mog-secrets"
    fi
fi

# Add to fstab if not already present
if ! grep -q "/mnt/titan" /etc/fstab; then
    echo "//192.168.1.167/titan /mnt/titan cifs credentials=/etc/mog-secrets,file_mode=0777,dir_mode=0777 0 0" >> /etc/fstab
    systemctl daemon-reload
fi

# Verify network connectivity to share
if ! ping -c 1 192.168.1.167 &>/dev/null; then
    echo "Error: Cannot reach network share at 192.168.1.167" >&2
    exit 1
fi

# Mount the drive with retry logic
if mountpoint -q /mnt/titan; then
    echo "Drive is already mounted"
else
    for i in {1..3}; do
        if mount /mnt/titan; then
            break
        elif [ $i -eq 3 ]; then
            echo "Failed to mount drive after 3 attempts" >&2
            echo "Debug info from dmesg:"
            dmesg | tail -n 20 | grep -i cifs
            exit 1
        else
            echo "Mount attempt $i failed, retrying in 2 seconds..."
            sleep 2
        fi
    done
fi

# Verify mount
if [ -w /mnt/titan ]; then
    echo "Titan drive mounted successfully at /mnt/titan"
    # Test write access
    if touch /mnt/titan/test_file 2>/dev/null; then
        echo "Success: Drive is writable and accessible"
        rm -f /mnt/titan/test_file
    else
        echo "Error: Could not write to drive" >&2
        exit 1
    fi
else
    echo "Error: Failed to mount Titan drive" >&2
    exit 1
fi

exit 0
