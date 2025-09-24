# Base configuration shared across all machines
{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home
  ];

  modules.home = {
    programs = {
      common.enable = true;
      direnv.enable = true;
      git.enable = true;
      helix.enable = true;
      nvim = {
        enable = true;
        distro = "nvchad";
      };
      ssh.enable = true;
    };
    secrets = {
      sops.enable = true;
    };
  };

  home = {
    username = "danny";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;

  news.display = "silent";
}