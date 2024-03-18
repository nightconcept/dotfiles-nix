{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./vscode
    ./wezterm
    ./zsh
  ];

  home.packages = with pkgs; [
    duf
    eza
    fastfetch
    fd
    fnm
    fzf
    ncdu
    neovim
    nmap
    pyenv
    rsync
    thefuck
    tldr
    tmux
    trash-cli
    wget
    zip
    zoxide

    audacious
    corectrl
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
    ungoogled-chromium
    kitty
    zoom
  ];
}