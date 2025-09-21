# Rinoa - Server configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Use pinned nixpkgs from npins
  sources = import ./npins;
  pinnedPkgs = import sources.nixpkgs {
    system = pkgs.system;
    config = config.nixpkgs.config;
  };
in {
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
  };


  # Enable Docker
  modules.nixos.docker.enable = true;

  # Enable Docker containers
  modules.nixos.docker.containers = {
    portainer.enable = true;
    watchtower.enable = true;
  };

  # Use pinned nixpkgs for this host
  # This ensures rinoa stays on a known-good nixpkgs revision
  nixpkgs.pkgs = pinnedPkgs;

  # System packages for server management
  environment.systemPackages = with pinnedPkgs; [
    home-manager
  ];

  system.stateVersion = "24.05";
}