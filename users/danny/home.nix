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
    wget
    zip
    zoxide

    audacious
    bandwhich
    corectrl
    calibre
    discord
    foliate
    hugo
    obsidian
    steam
    evince
    fontconfig
    ferdium
    fnm
    github-desktop
    hexchat
    libreoffice-fresh
    mpv
    nomachine-client
    pavucontrol
    protonup-qt
    spotify
    stretchly
    ungoogled-chromium
    vscode
    wezterm
    zoom
  ];

  imports = [
      ../../dots/zsh
      ../../dots/vscode
  ];

  home = {
    username = "danny";
    homeDirectory = "/home/danny";
    stateVersion = "23.11";
  };


  }