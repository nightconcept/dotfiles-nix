{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "celes";

  # Kernel specified at 6.1 to allow for power limit control
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # Display settings
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Do not touch
  system.stateVersion = "23.11";
}