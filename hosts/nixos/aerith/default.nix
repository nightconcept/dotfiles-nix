# Aerith - Plex media server
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  sources = import ./npins;
  pinnedPkgs = import sources.nixpkgs {
    system = "x86_64-linux";
    config = { allowUnfree = true; };
    overlays = [
      # Override Plex with latest flake version
      (import ../../overlays/flake-packages.nix {
        inherit inputs;
        overridePackages = [ "plex" ];
      })
    ];
  };
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use pinned nixpkgs with Plex override
  nixpkgs.pkgs = pinnedPkgs;

  # Disable nixpkgs.config since we're using an external pkgs instance
  nixpkgs.config = lib.mkForce {};

  # Networking
  modules.nixos.networking.base.hostName = "aerith";

  # Override bootloader for legacy BIOS (no EFI partition)
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      enable = true;
      device = "/dev/sda";  # Install GRUB to MBR
    };
  };

  # Existing modular configuration
  modules.nixos = {
    kernel.type = "lts";

    network = {
      networkManager = true;
      mdns = true;
    };

    services.plex = {
      enable = true;
      user = "danny";
      openFirewall = true;
    };

    # Hardware for server
    hardware.usbAutomount.enable = true;

    # Network storage
    storage.networkDrives = {
      enable = true;
      enableTitan = true;
    };

    # Security
    security.sops.enable = true;
  };

  services.openssh.enable = true;

  # System packages for server management
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  system.stateVersion = "23.11";
}
