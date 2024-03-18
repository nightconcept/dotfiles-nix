{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    duf
    dunst
    eza
    fd
    fnm
    fzf
    ncdu
    neofetch
    neovim
    nmap
    pyenv
    rofi
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
    waybar
    wezterm
    zoom
  ];

  imports = [
    ./programs
    ./desktops/hyprland
  ];

  home = {
    username = "danny";
    homeDirectory = "/home/danny";
    stateVersion = "23.11";
  };

  news = {
    display = "silent";
  };
}
