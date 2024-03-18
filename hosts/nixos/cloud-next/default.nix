{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    (import ./hosts/nixos/disko.nix {device = "/dev/nvme0n1";})
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

  # hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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
    networkmanagerapplet
    dunst
  ];

  # Do not touch
  system.stateVersion = "23.11";
}
