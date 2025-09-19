# Forgejo Actions Runner Configuration

This module configures self-hosted Forgejo Actions runners using the official Forgejo runner Docker image.

## Prerequisites

### 1. Get Registration Token from Forgejo

#### For Instance-wide Runners (Admin only)
1. Go to Site Administration → Actions → Runners
2. Click "Create new Runner"
3. Copy the registration token

#### For Organization Runners
1. Go to Organization Settings → Actions → Runners
2. Click "Create new Runner"
3. Copy the registration token

#### For Repository Runners
1. Go to Repository Settings → Actions → Runners
2. Click "Create new Runner"
3. Copy the registration token

### 2. Add Token to SOPS Secrets

Add your Forgejo registration token to your SOPS secrets file:

```yaml
# secrets/common.yaml
forgejo-runner-token: "your_registration_token_here"
```

Configure it in your NixOS sops configuration:

```nix
sops.secrets."forgejo-runner-token" = {
  sopsFile = ./secrets/common.yaml;
  path = "/run/secrets/forgejo-runner-token";
  mode = "0400";
};
```

## Configuration Options

### Basic Configuration

```nix
modules.nixos.docker.containers.forgejo-runner = {
  enable = true;
  replicas = 3;                                    # Number of concurrent runners
  instanceUrl = "https://git.yourdomain.com";     # Your Forgejo instance URL
  runnerName = "vincent-runner";                  # Base name for runners
  labels = [ "docker" "amd64" "linux" ];         # Runner labels
  tokenFile = "/run/secrets/forgejo-runner-token";
};
```

## Using Runners in Forgejo Actions

### In your workflow files (.forgejo/workflows/*.yml or .github/workflows/*.yml):

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    # Target runners by labels
    runs-on: docker
    # Or use multiple labels
    # runs-on: [docker, linux]

    steps:
      - uses: actions/checkout@v3
      - name: Run build
        run: |
          echo "Running on Forgejo self-hosted runner"
```

## How It Works

1. **Registration**: Runners use the registration token to register with your Forgejo instance
2. **Job Execution**: Runners poll for jobs matching their labels
3. **Docker-in-Docker**: Runners can execute Docker containers for job steps
4. **Ephemeral Nature**: Default behavior creates fresh environment for each job
5. **Scaling**: Multiple replicas allow concurrent job execution

## Forgejo Actions Compatibility

Forgejo Actions is designed to be compatible with GitHub Actions:
- Most GitHub Actions can be used directly
- Same workflow syntax
- Similar runner behavior

### Differences from GitHub Actions
- Registration uses tokens from Forgejo UI (not PATs)
- Some GitHub-specific actions may not work
- Forgejo-specific actions available in the Forgejo ecosystem

## Monitoring

### View Runner Status

#### Forgejo UI
Check runner status at:
- **Instance**: Site Admin → Actions → Runners
- **Organization**: Org Settings → Actions → Runners
- **Repository**: Repo Settings → Actions → Runners

#### Local Monitoring
```bash
# View running containers
docker ps | grep forgejo-runner

# Check container logs
docker logs forgejo-runner

# Monitor via Portainer (if enabled)
# http://vincent:9000
```

## Troubleshooting

### Runner Not Appearing in Forgejo

1. Verify registration token:
   ```bash
   cat /run/secrets/forgejo-runner-token
   ```

2. Check container logs:
   ```bash
   docker-compose -f /var/lib/docker-containers/forgejo-runner/docker-compose.yml logs
   ```

3. Ensure network connectivity to Forgejo instance

### Runner Shows Offline

- Check if container is running: `docker ps`
- Restart service: `systemctl restart docker-container-forgejo-runner`
- Verify Forgejo instance is accessible from runner

### Jobs Not Running

1. Verify workflow syntax is correct
2. Check labels match between workflow and runner
3. Ensure Actions are enabled in Forgejo settings
4. Check Forgejo logs for errors

### Registration Token Expired

Registration tokens can expire. To get a new one:
1. Go to Forgejo runner settings
2. Delete old runner if listed
3. Create new runner and get new token
4. Update SOPS secrets with new token
5. Restart runner service

## Security Considerations

- **Token Security**: Registration tokens should be kept secret
- **Network Security**: Ensure secure connection between runners and Forgejo
- **Resource Isolation**: Consider Docker resource limits for untrusted code
- **Secret Management**: Use SOPS or similar for token storage

## Advanced Configuration

### Custom Networks
Runners can be configured to use specific Docker networks for job containers.

### Volume Mounts
Additional volumes can be mounted for caching or shared resources.

### Resource Limits
CPU and memory limits can be set via Docker Compose configuration.

## Additional Resources

- [Forgejo Actions Documentation](https://forgejo.org/docs/latest/user/actions/)
- [Forgejo Runner Repository](https://code.forgejo.org/forgejo/runner)
- [Actions Compatibility List](https://forgejo.org/docs/latest/user/actions/#compatibility)