# Office Integration Configuration

This document describes the persistent configuration for Nextcloud with Collabora and OnlyOffice integration.

## Environment Variables Required

### All services (.env in nextcloud/ folder)
```bash
# Database configuration
DB_ROOT_PW=your_root_password
DB_USER=your_db_user
DB_PW=your_db_password

# Collabora configuration
COLLABORA_PASSWORD=changeme
LOG_DRIVER=local

# OnlyOffice configuration
JWT_SECRET=your_generated_secret_here
```

## Configuration Persistence

All configurations are set in docker-compose.yaml files to ensure they persist across container restarts:

### Nextcloud Configuration
- **Trusted Domains**: Set via `NEXTCLOUD_TRUSTED_DOMAINS` environment variable
- **HTTPS Overwrite**: Configured via `OVERWRITEPROTOCOL` and `OVERWRITECLIURL`
- **Proxy Settings**: `TRUSTED_PROXIES` set to Docker network range

### Collabora Configuration
- **WOPI Hosts**: Configured in `aliasgroup1` to accept connections from Nextcloud domains
- **SSL Settings**: Disabled internally, terminated at Traefik
- **Allowed Hosts**: Explicitly set in `extra_params` for both network names and domains

### OnlyOffice Configuration
- **JWT Security**: Enabled with secret from .env file
- **WOPI Support**: Enabled for Nextcloud integration
- **Private IP Access**: Allowed for container-to-container communication

## Deployment Order

1. **Start Traefik** (if not already running)
2. **Start the Complete Office Stack**:
   ```bash
   cd nextcloud
   docker compose up -d
   ```
3. **Run Initialization** (optional, configs should persist):
   ```bash
   ./init-nextcloud.sh
   ```

## Accessing Services

- **Nextcloud**: https://nextcloud.local.solivan.dev
- **Nextcloud (Cloudflare)**: https://nextcloud.solivan.dev
- **Collabora Admin**: https://collabora.local.solivan.dev/browser/dist/admin/admin.html
- **OnlyOffice**: https://onlyoffice.local.solivan.dev

## Troubleshooting

### Check Container Logs
```bash
docker logs nextcloud
docker logs collabora
docker logs onlyoffice
```

### Verify Collabora Connection
```bash
docker exec nextcloud php occ richdocuments:activate-config
```

### Verify OnlyOffice Settings
```bash
docker exec nextcloud php occ config:list | grep onlyoffice
```

### Reset Office App Configurations
```bash
# For Collabora
docker exec nextcloud php occ app:remove richdocuments
docker exec nextcloud php occ app:install richdocuments

# For OnlyOffice
docker exec nextcloud php occ app:remove onlyoffice
docker exec nextcloud php occ app:install onlyoffice
```

## Internal Communication

Services communicate internally via Docker network names:
- Nextcloud → Collabora: `http://collabora:9980`
- Nextcloud → OnlyOffice: `http://onlyoffice:80`
- OnlyOffice → Nextcloud: `http://nextcloud:80`

External users access all services via HTTPS through Traefik.