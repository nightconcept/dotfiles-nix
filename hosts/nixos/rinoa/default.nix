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
    };
    authelia = {
      enable = true;
      domain = "local.solivan.dev";
      subdomain = "auth";
    };
    ddclient.enable = true;
    portainer.enable = true;
    watchtower.enable = true;
  };

  # System packages for server management
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  system.stateVersion = "24.05";
}