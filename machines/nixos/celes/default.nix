
{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "celes";

  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    dosfstools
    duf
    eza
    fastfetch
    fd
    fnm
    fzf
    gcc
    git
    lazygit
    wget
    ncdu
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
    zsh
    
    audacious
    bandwhich
    corectrl
    calibre
    discord
    firefox
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

  # Do not touch
  system.stateVersion = "23.11";

}
