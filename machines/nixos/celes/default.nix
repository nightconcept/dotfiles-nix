{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "celes";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    corectrl
  ];

  # Do not touch
  system.stateVersion = "23.11";

}
