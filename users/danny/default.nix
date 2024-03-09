{ config, pkgs, lib, ... }: 
{
  imports = [
    #../../dots/zsh
    # ../../dots/nvim
    # ../../dots/git
  ];

  programs.nix-index =
  {
    enable = true;
    enableZshIntegration = true;
  };

  programs.home-manager.enable = true;
}