{ inputs, lib, pkgs,  ... }: 
{
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    duf
    eza
    fd
    fnm
    fzf
    git
    gh
    lazygit
    ncdu
    neofetch
    neovim
    nmap
    pyenv
    rsync
    speedtest-cli
    stow
    thefuck
    tldr
    tmux
    trash-cli
    vim
    wget
    zip
    zoxide
  ];

  imports = [
      ../../dots/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };


  }