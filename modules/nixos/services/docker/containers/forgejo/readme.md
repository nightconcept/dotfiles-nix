# Forgejo

Forgejo is a self-hosted lightweight software forge. Easy to install and low maintenance, it just does the job.

## Service Details
- **URL**: https://forge.solivan.dev
- **SSH**: Port 2222
- **Container**: codeberg.org/forgejo/forgejo:11
- **Database**: PostgreSQL 16

## Initial Setup

1. Create environment file:
```bash
cat > .env << EOF
DB_PASSWORD=your_secure_password_here
EOF
```

2. Create configuration directories:
```bash
mkdir -p ~/config/forgejo/data
mkdir -p ~/config/forgejo/db
```

3. Start the service:
```bash
docker compose up -d
```

4. Access Forgejo at https://forge.solivan.dev and complete initial setup

## SSH Configuration

To use SSH for git operations, configure your SSH client:

```bash
# Add to ~/.ssh/config
Host forge.local.solivan.dev
    Port 2222
    User git

Host forge.solivan.dev
    Port 2222
    User git
```

## Environment Variables

- `DB_PASSWORD`: PostgreSQL database password

## Volumes

- `~/config/forgejo/data`: Forgejo data and repositories
- `~/config/forgejo/db`: PostgreSQL database files

## Ports

- `2222`: SSH for git operations
- `3000`: Web interface (exposed via Traefik)