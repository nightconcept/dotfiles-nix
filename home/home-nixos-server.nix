{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;

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

  imports = [
    ./common.nix
    ./programs/direnv.nix
    ./programs/neovim.nix
    ./programs/shell
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };
}
