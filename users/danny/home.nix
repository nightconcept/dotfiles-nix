{ inputs, lib, pkgs,  ... }: 
{
  imports = [
      ../../dots/zsh
  ];

  programs.home-manager.enable = true;
  }