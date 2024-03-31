{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./direnv.nix
    ./gaming.nix
    ./git.nix
    ./ssh.nix
    ./vscode.nix
    ./wezterm
    ./zsh
  ];

  home.packages = with pkgs; [
    audacious
    foliate
    obsidian
    evince
    fontconfig
    ferdium
    hexchat
    libreoffice-fresh
    mpv
    nomachine-client
    pavucontrol
    spotify
    ungoogled-chromium
    zoom
  ];
}
