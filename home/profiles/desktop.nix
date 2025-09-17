# Linux (non-NixOS) Desktops
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../programs/common.nix
    ../programs/spicetify.nix
    ../programs/wezterm
    ../stylix.nix
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

  programs.spicetify.enable = true;

  stylix.targets.gtk.enable = lib.mkForce false;

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/x-github-desktop-dev-auth" = "github-desktop.desktop";
    };
  };
}
