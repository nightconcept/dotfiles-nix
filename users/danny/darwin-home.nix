{ inputs, lib, pkgs,  ... }: 
{
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  imports = [
      ../../dots/zsh
      ../../dots/vscode
  ];

  }