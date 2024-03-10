{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "cloud";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    acpi
    tlp
  ];

  # Do not touch
  system.stateVersion = "23.11";
}