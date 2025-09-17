# Laptop-specific configuration (power management, battery, etc)
{ config, lib, pkgs, ... }:

{
  # Laptop profiles always include desktop
  imports = [
    ./desktop.nix
  ];

  # Laptop-specific packages could go here
  # home.packages = with pkgs; [
  #   powertop
  #   tlp
  # ];

  # Laptop-specific configuration
  # For example, battery display is already handled in waybar.nix
  # Power management would be in system configuration, not home-manager
}