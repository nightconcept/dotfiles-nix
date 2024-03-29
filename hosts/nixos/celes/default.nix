{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    hyprland.enable = true;

    networking.hostName = "celes";

    boot.kernelPackages = pkgs.linuxPackages_6_7;

    system.stateVersion = "23.11";
  };
}
