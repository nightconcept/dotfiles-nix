# Desktop configuration for GUI environments
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../programs/common.nix
    ../programs/gaming.nix
    ../programs/spicetify.nix
    ../programs/wezterm
    ../stylix.nix
    ../desktops/hyprland
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    github-desktop
    kdePackages.xdg-desktop-portal-kde
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    obsidian
    uv
    vlc
    vscode
    xdg-utils
  ];

  desktops.hyprland.enable = true;

  programs.spicetify.enable = true;

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/x-github-desktop-dev-auth" = "github-desktop.desktop";
    };
  };
}
