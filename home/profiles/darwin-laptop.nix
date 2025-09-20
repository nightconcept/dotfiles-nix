# macOS laptop-specific configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./darwin-desktop.nix
    ../desktops/aerospace
  ];

  modules.home.programs = {
    firefox.enable = true;
    shell = {
      fish.enable = true;
      starship.enable = true;
      zoxide.enable = true;
    };
  };

  desktops.aerospace.enable = true;

  # macOS laptops use shell instead of zsh
  # (included via default.nix based on hostname)
}