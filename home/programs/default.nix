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
    #./vscode.nix
    ./wezterm
    ./xdg.nix
    ./zsh
  ];

  home.packages = with pkgs; [
    audacious
    foliate
    obsidian
    evince
    fontconfig
    github-desktop
    hexchat
    mpv
    nomachine-client
    pavucontrol
    spotify
    ungoogled-chromium
    zoom
  ];
}
