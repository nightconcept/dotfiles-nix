{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "celes";

  # Do not touch
  system.stateVersion = "23.11";

}
