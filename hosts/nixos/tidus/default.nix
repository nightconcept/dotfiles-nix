{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.dell-latitude-7420
  ];

  config = {
    # Enable Hyprland instead of Plasma
    hyprland.enable = true;

    # Explicitly disable GNOME and Plasma
    services.desktopManager.gnome.enable = false;
    services.displayManager.gdm.enable = false;

    networking.hostName = "tidus";

    boot.kernelPackages = pkgs.linuxPackages_zen;

    # Allow unfree packages for Spotify
    nixpkgs.config.allowUnfree = true;

    # Install Firefox at system level for tidus only
    environment.systemPackages = with pkgs; [
      firefox
    ];

    system.stateVersion = "23.11";
  };
}
