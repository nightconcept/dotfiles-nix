# Minimal server configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ../programs/common.nix
    ../programs/shell
  ];

  # Additional server-specific packages
  home.packages = with pkgs; [
    lazydocker
  ];
}