# Base configuration shared across all machines
{ config, lib, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../programs/direnv.nix
    ../programs/git.nix
    ../programs/helix.nix
    ../programs/ssh.nix
    ../secrets/sops.nix
  ];

  home = {
    username = "danny";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
}