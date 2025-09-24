# Dokploy Setup on Vincent

This document describes the Dokploy PaaS setup on the Vincent host, integrated with rinoa's Traefik for external routing.

## Architecture

### Vincent (Dokploy Host)
- **Dokploy**: Self-hosted PaaS platform for application deployment
- **Ports**:
  - 3000: Dokploy dashboard UI
  - 8080: Dokploy's Traefik HTTP (internal)
  - 8443: Dokploy's Traefik HTTPS (internal)
- **Services**: PostgreSQL, Redis, Traefik (all managed by Dokploy)
- **Docker Swarm**: Enabled with `live-restore: false` for compatibility

### Rinoa (Main Traefik)
- Routes external traffic to Vincent's Dokploy instance
- Handles SSL termination for `*.local.solivan.dev`
- Forwards requests to Vincent via mDNS (`vincent.local`)

## URLs

Once deployed, Dokploy will be accessible at:
- **Dashboard**: `https://dokploy.local.solivan.dev`
- **Applications**: `https://*.apps.local.solivan.dev`

## Deployment Steps

### 1. Deploy to Vincent

```bash
# On Vincent host
sudo nixos-rebuild switch --flake github:nightconcept/dotfiles-nix#vincent
```

This will:
- Install and configure Dokploy
- Set up Docker Swarm mode
- Configure custom Traefik ports (8080/8443)
- Start Dokploy services

### 2. Deploy to Rinoa

```bash
# On Rinoa host
sudo nixos-rebuild switch --flake github:nightconcept/dotfiles-nix#rinoa
```

This will:
- Update Traefik configuration with Dokploy routing
- Set up proxy rules for `dokploy.local.solivan.dev`
- Configure wildcard routing for `*.apps.local.solivan.dev`

## Configuration

### Vincent Configuration
Located in `/hosts/nixos/vincent/default.nix`:
```nix
services.dokploy = {
  enable = true;
  dataDir = "/var/lib/dokploy";
};
```

### Rinoa Configuration
Located in `/hosts/nixos/rinoa/default.nix`:
```nix
modules.nixos.docker.containers.traefik = {
  dokployIntegration = {
    enable = true;
    host = "vincent.local";
    dashboardSubdomain = "dokploy";
    appsSubdomain = "apps";
  };
};
```

## Network Requirements

- Both hosts must be on the same network
- mDNS must be enabled for `.local` hostname resolution
- Firewall ports must be open on Vincent (3000, 8080, 8443)

## Troubleshooting

### If vincent.local doesn't resolve
Add a static host entry to rinoa:
```nix
networking.hosts = {
  "192.168.1.XXX" = [ "vincent.local" ];  # Replace XXX with Vincent's IP
};
```

### Check Dokploy services on Vincent
```bash
sudo systemctl status dokploy-stack
sudo systemctl status dokploy-traefik
docker stack ps dokploy
```

### Check Traefik routing on Rinoa
```bash
sudo docker logs traefik
curl -I https://dokploy.local.solivan.dev
```

## Using Dokploy

Once deployed, you can:
1. Access the dashboard at `https://dokploy.local.solivan.dev`
2. Set up your admin account on first login
3. Deploy applications using:
   - Git repositories
   - Docker images
   - Docker Compose files
   - Nixpacks or Buildpacks

Each deployed application will get a subdomain under `*.apps.local.solivan.dev` automatically.

## Security Notes

- Dokploy dashboard should be protected (consider adding authentication)
- Internal traffic between rinoa and vincent uses self-signed certificates
- Database password is hardcoded in Dokploy (known limitation)

## References

- [Dokploy Documentation](https://docs.dokploy.com)
- [nix-dokploy Module](https://github.com/el-kurto/nix-dokploy)