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
    btop
    duf
    eza
    fd
    fzf
    git
    gh
    lazydocker
    lazygit
    ncdu
    neovim
    nmap
    rsync
    speedtest-cli
    tmux
    trash-cli
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
