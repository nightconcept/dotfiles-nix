{ inputs, lib, pkgs,  ... }: 
{
  imports = [
      ../../dots/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = "/home/danny";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
  }