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

  # Enable Docker module
  modules.nixos.docker.enable = true;

  # CI/CD Runners
  services.ci-runners = {
    enable = true;

    github = {
      enable = true;
      replicas = 3;
      ephemeral = true;
      owner = "nightconcept";
      repo = null;  # Organization-wide runners
      labels = [ "docker" "self-hosted" "linux" "x64" "vincent" ];
      tokenFile = config.sops.secrets."ci_runners/github_token".path;
    };

    forgejo = {
      enable = true;
      replicas = 3;
      instanceUrl = "https://forge.local.solivan.dev";
      labels = [ "docker" "amd64" "linux" "vincent" ];
      tokenFile = config.sops.secrets."ci_runners/forgejo_token".path;
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

  # System state version
  system.stateVersion = "24.11";
}
