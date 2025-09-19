#!/bin/bash
# Nextcloud initialization script - runs after container starts
# This ensures all configurations persist across container restarts

echo "Waiting for Nextcloud to be ready..."
until docker exec nextcloud php occ status --no-warnings 2>/dev/null | grep -q "installed: true"; do
    sleep 5
done

echo "Configuring Nextcloud settings..."

# Set trusted domains
docker exec nextcloud php occ config:system:set trusted_domains 0 --value=localhost
docker exec nextcloud php occ config:system:set trusted_domains 1 --value=nextcloud.local.solivan.dev
docker exec nextcloud php occ config:system:set trusted_domains 2 --value=nextcloud.solivan.dev

# Set HTTPS overwrite settings for reverse proxy
docker exec nextcloud php occ config:system:set overwriteprotocol --value=https
docker exec nextcloud php occ config:system:set overwrite.cli.url --value=https://nextcloud.local.solivan.dev

# Configure Collabora (Nextcloud Office)
if docker exec nextcloud php occ app:list | grep -q "richdocuments"; then
    echo "Configuring Collabora integration..."
    docker exec nextcloud php occ app:enable richdocuments
    docker exec nextcloud php occ config:app:set richdocuments wopi_url --value="https://collabora.local.solivan.dev"
    docker exec nextcloud php occ richdocuments:activate-config
fi

# Configure OnlyOffice
if docker exec nextcloud php occ app:list | grep -q "onlyoffice"; then
    echo "Configuring OnlyOffice integration..."
    docker exec nextcloud php occ app:enable onlyoffice
    
    # Get JWT secret from environment variable
    if [ ! -z "$JWT_SECRET" ]; then
        docker exec nextcloud php occ config:app:set onlyoffice jwt_secret --value="$JWT_SECRET"
    fi
    
    docker exec nextcloud php occ config:app:set onlyoffice DocumentServerUrl --value="https://onlyoffice.local.solivan.dev/"
    docker exec nextcloud php occ config:app:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice:80"
    docker exec nextcloud php occ config:app:set onlyoffice StorageUrl --value="http://nextcloud:80"
    docker exec nextcloud php occ config:app:set onlyoffice jwt_header --value=""
fi

echo "Nextcloud configuration complete!"
echo "Current trusted domains:"
docker exec nextcloud php occ config:system:get trusted_domains