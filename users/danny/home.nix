{ inputs, lib, pkgs,  ... }: 
{
  imports = [
      ../../dots/zsh
      ../../dots/vscode
  ];

  home = {
    username = "danny";
    homeDirectory = "/home/danny";
    stateVersion = "23.11";
  };

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
  }