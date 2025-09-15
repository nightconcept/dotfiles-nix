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

    networking.hostName = "tidus";

    boot.kernelPackages = pkgs.linuxPackages_6_12;

    system.stateVersion = "23.11";
  };
}
