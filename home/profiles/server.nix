# Minimal server configuration
{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    btop
    duf
    eza
    git
    lazydocker
    lazygit
    ncdu
    nmap
    rsync
    vim
    wget
    zip
  ];

  # Server uses shell but not the full desktop shell config
  imports = [
    ../programs/shell
  ];
}