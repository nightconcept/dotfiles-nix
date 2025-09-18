# Base configuration shared across all machines
{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home
    ../programs/direnv.nix
    ../programs/git.nix
    ../programs/helix.nix
    ../programs/ssh.nix
    ../secrets/sops.nix
  ];

  modules.home = {
    programs.common.enable = true;
  };

  home = {
    username = "danny";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
}