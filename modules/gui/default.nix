
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
}