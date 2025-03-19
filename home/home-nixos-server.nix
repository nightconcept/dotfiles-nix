{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;

  news = {
    display = "silent";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home.packages = with pkgs; [
    bat
    btop
    duf
    eza
    git
    gh
    lazydocker
    lazygit
    ncdu
    neovim
    nmap
    rsync
    vim
    wget
    zip
    zoxide
  ];

  imports = [
    ./programs/direnv.nix
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };
}
