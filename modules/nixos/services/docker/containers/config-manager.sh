#!/usr/bin/env bash

# Config Manager Script for Homelab Containers
# This script helps backup and restore configuration files from ~/config to version control

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_HOME="${HOME}/config"
REPO_CONFIGS_DIR="./configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Services to manage (add more as needed)
SERVICES=(
    "traefik"
    "authelia"
    "portainer"
    "homepage"
    "watchtower"
    "nextcloud"
    "searxng"
    "open-webui"
)

# Function to print colored messages
print_msg() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Function to check if service config exists
check_service_config() {
    local service=$1
    if [ -d "${CONFIG_HOME}/${service}" ]; then
        return 0
    else
        return 1
    fi
}

# Function to backup configs to repo
backup_configs() {
    print_msg $BLUE "Starting configuration backup..."
    
    # Create configs directory if it doesn't exist
    mkdir -p "${REPO_CONFIGS_DIR}"
    
    local backed_up=0
    local skipped=0
    
    for service in "${SERVICES[@]}"; do
        if check_service_config "$service"; then
            print_msg $YELLOW "Backing up ${service}..."
            
            # Create service directory in repo
            mkdir -p "${REPO_CONFIGS_DIR}/${service}"
            
            # Special handling for different services
            case "$service" in
                traefik)
                    # Copy traefik.yml and dynamic configs, but not acme.json
                    if [ -f "${CONFIG_HOME}/${service}/traefik.yml" ]; then
                        cp "${CONFIG_HOME}/${service}/traefik.yml" "${REPO_CONFIGS_DIR}/${service}/"
                        print_msg $GREEN "  ✓ traefik.yml"
                    fi
                    if [ -f "${CONFIG_HOME}/${service}/dynamic.yml" ]; then
                        cp "${CONFIG_HOME}/${service}/dynamic.yml" "${REPO_CONFIGS_DIR}/${service}/"
                        print_msg $GREEN "  ✓ dynamic.yml"
                    fi
                    # Create acme.json placeholder if it doesn't exist
                    if [ ! -f "${REPO_CONFIGS_DIR}/${service}/acme.json.placeholder" ]; then
                        echo "# This file is a placeholder. The actual acme.json will be created by Traefik" > "${REPO_CONFIGS_DIR}/${service}/acme.json.placeholder"
                    fi
                    ;;
                authelia)
                    # Copy configuration.yml but not secrets
                    if [ -f "${CONFIG_HOME}/${service}/configuration.yml" ]; then
                        cp "${CONFIG_HOME}/${service}/configuration.yml" "${REPO_CONFIGS_DIR}/${service}/"
                        print_msg $GREEN "  ✓ configuration.yml"
                    fi
                    if [ -f "${CONFIG_HOME}/${service}/users_database.yml" ]; then
                        # Create sanitized version without passwords
                        print_msg $YELLOW "  ! Creating sanitized users_database.yml (passwords removed)"
                        sed 's/password:.*/password: REDACTED/' "${CONFIG_HOME}/${service}/users_database.yml" > "${REPO_CONFIGS_DIR}/${service}/users_database.yml.example"
                    fi
                    ;;
                *)
                    # Generic backup - copy all non-sensitive files
                    find "${CONFIG_HOME}/${service}" -type f \
                        ! -name "*.db" \
                        ! -name "*.sqlite" \
                        ! -name "*.log" \
                        ! -name "*.key" \
                        ! -name "*.pem" \
                        ! -name "*.crt" \
                        ! -name "*.secret" \
                        -exec cp {} "${REPO_CONFIGS_DIR}/${service}/" \; 2>/dev/null || true
                    print_msg $GREEN "  ✓ Configuration files copied"
                    ;;
            esac
            
            ((backed_up++))
        else
            print_msg $YELLOW "  ⊗ ${service} config not found in ${CONFIG_HOME}/${service}"
            ((skipped++))
        fi
    done
    
    print_msg $GREEN "\nBackup complete: ${backed_up} services backed up, ${skipped} skipped"
    print_msg $BLUE "Remember to commit these changes to version control!"
}

# Function to restore configs from repo
restore_configs() {
    print_msg $BLUE "Starting configuration restore..."
    
    if [ ! -d "${REPO_CONFIGS_DIR}" ]; then
        print_msg $RED "Error: No configs directory found in repository!"
        exit 1
    fi
    
    # Create backup of existing configs
    if [ -d "${CONFIG_HOME}" ]; then
        print_msg $YELLOW "Creating backup of existing configs..."
        sudo tar -czf "${HOME}/config_backup_${TIMESTAMP}.tar.gz" -C "${HOME}" config 2>/dev/null || true
        print_msg $GREEN "Backup saved to ${HOME}/config_backup_${TIMESTAMP}.tar.gz"
    fi
    
    local restored=0
    local skipped=0
    
    for service in "${SERVICES[@]}"; do
        if [ -d "${REPO_CONFIGS_DIR}/${service}" ]; then
            print_msg $YELLOW "Restoring ${service}..."
            
            # Create service config directory
            mkdir -p "${CONFIG_HOME}/${service}"
            
            # Special handling for different services
            case "$service" in
                traefik)
                    # Copy traefik configs
                    if [ -f "${REPO_CONFIGS_DIR}/${service}/traefik.yml" ]; then
                        cp "${REPO_CONFIGS_DIR}/${service}/traefik.yml" "${CONFIG_HOME}/${service}/"
                        print_msg $GREEN "  ✓ traefik.yml"
                    fi
                    if [ -f "${REPO_CONFIGS_DIR}/${service}/dynamic.yml" ]; then
                        cp "${REPO_CONFIGS_DIR}/${service}/dynamic.yml" "${CONFIG_HOME}/${service}/"
                        print_msg $GREEN "  ✓ dynamic.yml"
                    fi
                    # Create acme.json with correct permissions
                    if [ ! -f "${CONFIG_HOME}/${service}/acme.json" ]; then
                        touch "${CONFIG_HOME}/${service}/acme.json"
                        chmod 600 "${CONFIG_HOME}/${service}/acme.json"
                        print_msg $GREEN "  ✓ acme.json created with correct permissions"
                    fi
                    ;;
                authelia)
                    # Copy authelia configs
                    if [ -f "${REPO_CONFIGS_DIR}/${service}/configuration.yml" ]; then
                        cp "${REPO_CONFIGS_DIR}/${service}/configuration.yml" "${CONFIG_HOME}/${service}/"
                        print_msg $GREEN "  ✓ configuration.yml"
                    fi
                    if [ -f "${REPO_CONFIGS_DIR}/${service}/users_database.yml.example" ]; then
                        print_msg $YELLOW "  ! Found users_database.yml.example"
                        print_msg $YELLOW "    Please manually create users_database.yml with proper passwords"
                    fi
                    ;;
                *)
                    # Generic restore
                    cp -r "${REPO_CONFIGS_DIR}/${service}/"* "${CONFIG_HOME}/${service}/" 2>/dev/null || true
                    print_msg $GREEN "  ✓ Configuration files restored"
                    ;;
            esac
            
            ((restored++))
        else
            print_msg $YELLOW "  ⊗ No backup found for ${service}"
            ((skipped++))
        fi
    done
    
    print_msg $GREEN "\nRestore complete: ${restored} services restored, ${skipped} skipped"
}

# Function to show differences
diff_configs() {
    print_msg $BLUE "Comparing live configs with repository..."
    
    for service in "${SERVICES[@]}"; do
        if check_service_config "$service" && [ -d "${REPO_CONFIGS_DIR}/${service}" ]; then
            print_msg $YELLOW "\nChecking ${service}..."
            
            case "$service" in
                traefik)
                    for file in traefik.yml dynamic.yml; do
                        if [ -f "${CONFIG_HOME}/${service}/${file}" ] && [ -f "${REPO_CONFIGS_DIR}/${service}/${file}" ]; then
                            if diff -q "${CONFIG_HOME}/${service}/${file}" "${REPO_CONFIGS_DIR}/${service}/${file}" > /dev/null; then
                                print_msg $GREEN "  ✓ ${file} is in sync"
                            else
                                print_msg $RED "  ✗ ${file} has differences"
                                if [ "$VERBOSE" = "true" ]; then
                                    diff -u "${REPO_CONFIGS_DIR}/${service}/${file}" "${CONFIG_HOME}/${service}/${file}" || true
                                fi
                            fi
                        fi
                    done
                    ;;
                *)
                    # Generic comparison
                    for file in "${REPO_CONFIGS_DIR}/${service}"/*; do
                        if [ -f "$file" ]; then
                            basename_file=$(basename "$file")
                            if [ -f "${CONFIG_HOME}/${service}/${basename_file}" ]; then
                                if diff -q "${CONFIG_HOME}/${service}/${basename_file}" "$file" > /dev/null; then
                                    print_msg $GREEN "  ✓ ${basename_file} is in sync"
                                else
                                    print_msg $RED "  ✗ ${basename_file} has differences"
                                fi
                            fi
                        fi
                    done
                    ;;
            esac
        fi
    done
}

# Function to validate configs
validate_configs() {
    print_msg $BLUE "Validating configuration files..."
    
    local errors=0
    
    # Check Traefik config
    if [ -f "${CONFIG_HOME}/traefik/traefik.yml" ]; then
        print_msg $YELLOW "Checking Traefik configuration..."
        if docker run --rm -v "${CONFIG_HOME}/traefik/traefik.yml:/traefik.yml:ro" traefik:latest traefik --configfile=/traefik.yml --check 2>/dev/null; then
            print_msg $GREEN "  ✓ Traefik configuration is valid"
        else
            print_msg $RED "  ✗ Traefik configuration has errors"
            ((errors++))
        fi
    fi
    
    if [ $errors -eq 0 ]; then
        print_msg $GREEN "\nAll configurations validated successfully!"
    else
        print_msg $RED "\nFound $errors configuration error(s)"
        return 1
    fi
}

# Main menu
show_menu() {
    echo
    print_msg $BLUE "=== Homelab Config Manager ==="
    echo "1) Backup configs to repository"
    echo "2) Restore configs from repository"
    echo "3) Compare live vs repository configs"
    echo "4) Validate configuration files"
    echo "5) Initialize config structure"
    echo "6) Exit"
    echo
    read -p "Select option: " choice
}

# Initialize config structure
init_configs() {
    print_msg $BLUE "Initializing configuration structure..."
    
    # Create configs directory
    mkdir -p "${REPO_CONFIGS_DIR}"
    
    # Create README for configs
    cat > "${REPO_CONFIGS_DIR}/README.md" << 'EOF'
# Configuration Files

This directory contains version-controlled configuration files for homelab services.

## Structure

Each service has its own directory containing its configuration files.

## Security Notes

- Sensitive files (passwords, keys, certificates) are NOT stored here
- Use `.example` files for templates that require secrets
- The actual `~/config` directory should be backed up separately for full recovery

## Usage

Use the `config-manager.sh` script to:
- Backup configs from `~/config` to this repository
- Restore configs from this repository to `~/config`
- Compare and validate configurations

```bash
./config-manager.sh
```
EOF
    
    print_msg $GREEN "Configuration structure initialized!"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backup|-b)
            backup_configs
            exit 0
            ;;
        --restore|-r)
            restore_configs
            exit 0
            ;;
        --diff|-d)
            diff_configs
            exit 0
            ;;
        --validate|-v)
            validate_configs
            exit 0
            ;;
        --init|-i)
            init_configs
            exit 0
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --backup, -b     Backup configs to repository"
            echo "  --restore, -r    Restore configs from repository"
            echo "  --diff, -d       Compare live vs repository configs"
            echo "  --validate, -v   Validate configuration files"
            echo "  --init, -i       Initialize config structure"
            echo "  --verbose        Show detailed output"
            echo "  --help, -h       Show this help message"
            exit 0
            ;;
        *)
            print_msg $RED "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Interactive mode
while true; do
    show_menu
    case $choice in
        1)
            backup_configs
            ;;
        2)
            restore_configs
            ;;
        3)
            diff_configs
            ;;
        4)
            validate_configs
            ;;
        5)
            init_configs
            ;;
        6)
            print_msg $GREEN "Goodbye!"
            exit 0
            ;;
        *)
            print_msg $RED "Invalid option!"
            ;;
    esac
done