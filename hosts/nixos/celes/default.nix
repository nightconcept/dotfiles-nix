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
    plasma6.enable = true;

    networking.hostName = "celes";

    boot.kernelPackages = pkgs.linuxPackages_6_11;

    system.stateVersion = "23.11";
  };
}
