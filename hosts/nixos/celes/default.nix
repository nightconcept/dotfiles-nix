{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../../systems/nixos/desktops/hyprland
    ../../../systems/nixos/network.nix
  ];

  networking.hostName = "celes";

  # Kernel specified at 6.1 to allow for GPU power limit control
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  # Display settings
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # System available packages
  environment.systemPackages = with pkgs; [
    firefox
    home-manager
  ];

  # Do not touch
  system.stateVersion = "23.11";
}
