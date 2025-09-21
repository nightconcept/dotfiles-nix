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
  ];

  # Apply shared overlays
  nixpkgs.overlays = [
    (import ../../../overlays/unstable-packages.nix { inherit inputs; })
  ];

  # Networking
  modules.nixos.networking.base.hostName = "vincent";

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

  # Enable Docker module and containers
  modules.nixos.docker = {
    enable = true;

    containers = {
      # GitHub Actions runners
      github-runner = {
        enable = true;
        replicas = 3;
        ephemeral = true;
        scope = "org";  # Organization-wide runners
        owner = "nightconcept";  # Your GitHub org/username
        repo = null;  # Not needed for org-wide runners
        labels = [ "docker" "self-hosted" "linux" "x64" "vincent" ];
        tokenFile = "/run/secrets/github-runner-token";
      };

      # Forgejo runners
      forgejo-runner = {
        enable = true;
        replicas = 3;
        instanceUrl = "https://forge.local.solivan.dev";  # Update this
        runnerName = "vincent-runner";
        labels = [ "docker" "amd64" "linux" "vincent" ];
        tokenFile = "/run/secrets/forgejo-runner-token";
      };

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
  };

  # System state version
  system.stateVersion = "24.11";
}