# Rinoa - Server configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # TODO: Add after pushing changes: ./dokploy-routing.nix  # Route traffic to Vincent's Dokploy
  ];

  # Bootloader configuration (override any systemd-boot settings)
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  # Swap configuration - 8GB swap file
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192; # 8GB in MB
    }
  ];

  # Apply shared overlays
  nixpkgs.overlays = [
    (import ../../../overlays/unstable-packages.nix { inherit inputs; })
  ];

  # Networking
  modules.nixos.networking.base.hostName = "rinoa";

  # Standard NixOS modules
  modules.nixos = {
    kernel.type = "lts";

    network = {
      networkManager = true;
      mdns = true;
    };

    # Enable SOPS for secret management
    security.sops.enable = true;

    # Enable titan network drive mount
    network-drives.titan = {
      enable = true;
      # Disable automount timeout to prevent services from stopping
      # Sonarr and Radarr require this mount, and the 60s timeout causes them to stop
      idleTimeout = 0;
    };
  };


  # Enable Docker
  modules.nixos.docker.enable = true;

  # Enable Docker containers
  modules.nixos.docker.containers = {
    traefik = {
      enable = true;
      domain = "local.solivan.dev";
      dashboard.enable = true;
      # cloudflareTokenFile automatically uses SOPS when sops.enable = true

      # Enable Dokploy routing to Vincent
      dokployIntegration = {
        enable = true;
        host = "vincent.local";  # Use mDNS hostname
        dashboardSubdomain = "dokploy";
        appsSubdomain = "apps";
      };
    };
    authelia = {
      enable = true;
      domain = "local.solivan.dev";
      subdomain = "auth";
    };
    ddclient.enable = true;
    portainer.enable = true;
    watchtower.enable = true;
    flaresolverr.enable = true;
    cloudflare-tunnel.enable = true;
    vaultwarden.enable = true;
    prowlarr-abb.enable = true;
    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    audiobookshelf.enable = true;
    nextcloud.enable = false;
    immich.enable = true;
    jellyfin.enable = true;
    homepage.enable = true;
    uptime-kuma.enable = true;
  };

  # System packages for server management
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  system.stateVersion = "24.05";
}