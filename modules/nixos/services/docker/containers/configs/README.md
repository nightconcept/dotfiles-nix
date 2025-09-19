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
