# Vincent - CI/CD Runner Host
# Purpose: Container orchestration for GitHub and Forgejo runners
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nix-dokploy.nixosModules.default
  ];

  # Apply shared overlays
  nixpkgs.overlays = [
    (import ../../../overlays/unstable-packages.nix { inherit inputs; })
  ];

  # Networking
  modules.nixos.networking.base.hostName = "vincent";

  # Bootloader configuration (override systemd-boot for BIOS/MBR systems)
  modules.nixos.core.bootloader.enable = false;
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      device = "/dev/sda"; # Update this to match your actual disk
    };
  };

  # Standard NixOS modules
  modules.nixos = {
    kernel.type = "lts";

    network = {
      networkManager = true;
      mdns = true;
    };
  };


  # System packages for server management
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  # Enable Docker module with Swarm support for Dokploy
  modules.nixos.docker = {
    enable = true;
    # Dokploy requires Docker Swarm which needs live-restore disabled
    swarm.enable = true;
  };

  # CI/CD Runners
  services.ci-runners = {
    enable = true;

    github = {
      enable = true;
      replicas = 3;
      ephemeral = true;
      owner = "nightconcept";
      repo = "dotfiles-nix";  # Repository-specific runners for user account
      labels = [ "docker" "self-hosted" "linux" "x64" "vincent" ];
      tokenFile = "/run/secrets/ci_runners/github_token";
    };

    forgejo = {
      enable = true;
      replicas = 3;
      instanceUrl = "https://forge.solivan.dev";
      labels = [ "docker" "amd64" "linux" "vincent" ];
      tokenFile = "/run/secrets/ci_runners/forgejo_token";
    };
  };

  # Additional container management
  modules.nixos.docker.containers = {
    # Container management
    portainer = {
      enable = true;
      port = 9000;
    };

    # Auto-update containers (optional)
    watchtower = {
      enable = false;  # Disabled by default for CI runners
      schedule = "0 0 4 * * *";
    };
  };

  # Dokploy PaaS configuration
  services.dokploy = {
    enable = true;
    dataDir = "/var/lib/dokploy";

    # Use custom ports to avoid conflicts with rinoa's Traefik
    # These will be proxied through rinoa
    # Default Dokploy UI is on port 3000
  };

  # Set environment variables for Dokploy to use custom Traefik ports
  systemd.services.dokploy-traefik.environment = {
    TRAEFIK_PORT = "8080";
    TRAEFIK_SSL_PORT = "8443";
  };

  # Open firewall for Dokploy services
  networking.firewall.allowedTCPPorts = [
    3000  # Dokploy UI
    8080  # Traefik HTTP
    8443  # Traefik HTTPS
  ];

  # System state version
  system.stateVersion = "24.11";
}
