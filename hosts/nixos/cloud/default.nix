{
  config,
  pkgs,
  inputs,
  ...
}: let
  nixos-path = "../../../systems/nixos";
in {
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    (import ${nixos-path}/disko.nix {device = "/dev/nvme0n1";})
    ${nixos-path}/wireless.nix
  ];

  # Kernel specified at 6.6 for the latest LTS
  boot.kernelPackages = pkgs.linuxPackages_6_7;

  networking.hostName = "cloud";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
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
    networkmanagerapplet
  ];

  # Do not touch
  system.stateVersion = "23.11";
}
