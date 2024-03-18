{ config, pkgs, inputs, ... }:
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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  # for hyprland
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  # Hint electron apps to use wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # System available packages
  environment.systemPackages = with pkgs; [
    firefox
    home-manager
  ];

  # Do not touch
  system.stateVersion = "23.11";
}