# Vincent - CI/CD Runner Host
# Purpose: Container orchestration for GitHub and Forgejo runners
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  sources = import ./npins;
  pinnedPkgs = import sources.nixpkgs {
    system = "x86_64-linux";
    config = {allowUnfree = true;};
  };
in {
  imports = [
    ./hardware-configuration.nix
    inputs.nix-dokploy.nixosModules.default
  ];

  # Use pinned nixpkgs
  nixpkgs.pkgs = pinnedPkgs;

  # Disable nixpkgs.config since we're using an external pkgs instance
  nixpkgs.config = lib.mkForce {};

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

    # Enable SOPS for secrets management
    security.sops.enable = true;
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

  # Forgejo Runners
  services.forgejo-runners = {
    enable = true;
    replicas = 3;
    labels = ["docker" "amd64" "linux" "vincent" "ubuntu-latest"];
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
      enable = false; # Disabled by default for CI runners
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

  # Override the dokploy-traefik service to use custom ports
  systemd.services.dokploy-traefik = {
    serviceConfig.ExecStart = lib.mkForce (
      let
        script = pkgs.writeShellApplication {
          name = "dokploy-traefik-start-custom";
          runtimeInputs = [pkgs.docker];
          text = ''
            if docker ps -a --format '{{.Names}}' | grep -q '^dokploy-traefik$'; then
              echo "Starting existing Traefik container..."
              docker start dokploy-traefik
            else
              echo "Creating and starting Traefik container with custom ports..."
              docker run -d \
                --name dokploy-traefik \
                --network dokploy-network \
                --restart=always \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v /var/lib/dokploy/traefik/traefik.yml:/etc/traefik/traefik.yml \
                -v /var/lib/dokploy/traefik/dynamic:/etc/dokploy/traefik/dynamic \
                -p 8080:80/tcp \
                -p 8443:443/tcp \
                -p 8443:443/udp \
                traefik:v3.5.0
            fi
          '';
        };
      in "${script}/bin/dokploy-traefik-start-custom"
    );
  };

  # Open firewall for Dokploy services
  networking.firewall.allowedTCPPorts = [
    3000 # Dokploy UI
    8080 # Traefik HTTP
    8443 # Traefik HTTPS
  ];

  # System state version
  system.stateVersion = "24.11";
}
