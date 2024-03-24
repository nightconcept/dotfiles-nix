{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../../systems/nixos/network.nix
  ];

  networking.hostName = "celes";

  # Kernel specified at 6.1 to allow for power limit control
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # Display settings
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

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
