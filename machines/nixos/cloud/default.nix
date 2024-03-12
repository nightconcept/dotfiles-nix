{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "cloud"; # Define your hostname.

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  environment.systemPackages = with pkgs; [
    acpi
    tlp
  ];

  # Do not touch
  system.stateVersion = "23.11";
}
