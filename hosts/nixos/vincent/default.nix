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
    replicas = 5;
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


  # System state version
  system.stateVersion = "24.11";
}
