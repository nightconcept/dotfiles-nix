{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];
  

  # Kernel specified at 6.6 for the latest LTS
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  networking.hostName = "cloud";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
    services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Hint electron apps to use wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    acpi
    firefox
    powertop
    hyprland
    swww
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xwayland
    waybar
    wofi
    networkmanagerapplet
    dunst
  ];
  
  # Do not touch
  system.stateVersion = "23.11";
}
