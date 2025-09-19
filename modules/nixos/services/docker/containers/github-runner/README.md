# GitHub Actions Runner Configuration

This module configures self-hosted GitHub Actions runners using the `myoung34/github-runner` Docker image.

## Prerequisites

### 1. Create a GitHub Personal Access Token (PAT)

#### For Organization-wide Runners
Create a PAT with the following scopes:
- `repo` (all)
- `admin:org` (all) - **mandatory for org runners**
- `workflow`
- Optional but recommended:
  - `admin:public_key` - read:public_key
  - `admin:repo_hook` - read:repo_hook
  - `admin:org_hook`
  - `notifications`

#### For Repository-specific Runners
Create a PAT with:
- `repo` (all)
- `workflow`

### 2. Configure Organization Settings (if using org-wide runners)

1. Go to your GitHub Organization Settings
2. Navigate to Actions → Runners
3. Enable "Allow public repositories" if needed
4. Note: You may need to enable `organization_self_hosted_runners` permission

### 3. Add Token to SOPS Secrets

Add your GitHub PAT to your SOPS secrets file:

```yaml
# secrets/common.yaml or secrets/user.yaml
github-runner-token: "ghp_your_token_here"
```

Then configure it in your NixOS sops configuration:

```nix
sops.secrets."github-runner-token" = {
  sopsFile = ./secrets/common.yaml;
  path = "/run/secrets/github-runner-token";
  mode = "0400";
};
```

## Configuration Options

### Organization-wide Runners (Recommended)

```nix
modules.nixos.docker.containers.github-runner = {
  enable = true;
  replicas = 3;              # Number of concurrent runners
  ephemeral = true;          # One job per container (recommended)
  scope = "org";             # Organization-wide
  owner = "your-org-name";   # Your GitHub organization/username
  repo = null;               # Not needed for org runners
  labels = [ "docker" "self-hosted" "linux" "x64" ];
  tokenFile = "/run/secrets/github-runner-token";
};
```

### Repository-specific Runners

```nix
modules.nixos.docker.containers.github-runner = {
  enable = true;
  replicas = 2;
  ephemeral = true;
  scope = "repo";            # Repository-specific
  owner = "your-username";   # GitHub username/org
  repo = "your-repo-name";   # Specific repository
  labels = [ "docker" "self-hosted" "linux" "x64" ];
  tokenFile = "/run/secrets/github-runner-token";
};
```

## Using the Runners in GitHub Actions

### In your workflow files (.github/workflows/*.yml):

```yaml
jobs:
  build:
    # For org-wide runners, use your labels
    runs-on: [self-hosted, linux, x64]

    # Or target specific runners
    runs-on: [self-hosted, linux, x64, vincent]

    steps:
      - uses: actions/checkout@v3
      - name: Run build
        run: |
          echo "Running on self-hosted runner"
```

## How It Works

1. **Authentication**: The container uses your PAT to dynamically register runners with GitHub
2. **Ephemeral Mode**: When enabled, each runner:
   - Picks up exactly one job
   - Runs it in a clean environment
   - Unregisters and terminates
   - Gets replaced by a new container
3. **Scaling**: The `replicas` setting determines how many concurrent jobs can run
4. **Labels**: Jobs can target runners based on labels in the workflow file

## Monitoring

### View Runner Status

#### GitHub UI
1. **Organization runners**: Organization Settings → Actions → Runners
2. **Repository runners**: Repository Settings → Actions → Runners

#### Local Monitoring
```bash
# View running containers
docker ps | grep github-runner

# Check logs
docker logs github-runner

# Use Portainer (if enabled)
# Access at http://vincent:9000
```

## Troubleshooting

### Runner Not Appearing in GitHub

1. Check token permissions:
   ```bash
   cat /run/secrets/github-runner-token
   ```

2. Check container logs:
   ```bash
   docker-compose -f /var/lib/docker-containers/github-runner/docker-compose.yml logs
   ```

3. Verify network connectivity to GitHub

### Runner Offline

- Ephemeral runners appear offline when not running jobs (this is normal)
- Check if container is running: `docker ps`
- Restart the service: `systemctl restart docker-container-github-runner`

### Jobs Not Being Picked Up

1. Verify labels match between workflow and runner configuration
2. Check organization/repository settings allow self-hosted runners
3. Ensure runner scope matches where workflows are defined

## Security Notes

- **Token Security**: Never commit tokens to git. Always use SOPS or similar secret management
- **Ephemeral Mode**: Recommended for security - ensures clean environment for each job
- **Network Isolation**: Consider network policies if runners need restricted access
- **Resource Limits**: Configure Docker resource limits if needed to prevent runaway jobs

## Additional Resources

- [myoung34/github-runner Documentation](https://github.com/myoung34/docker-github-actions-runner)
- [GitHub Self-hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)