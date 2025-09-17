# macOS-specific configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ../programs/zellij.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    karabiner-elements
  ];

  # macOS-specific imports based on whether it's a laptop or desktop
  # These are conditionally added in darwin-laptop.nix
}