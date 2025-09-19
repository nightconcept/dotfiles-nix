# Linux (non-NixOS) Desktops
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./base.nix
    ../../modules/home
  ];

  modules.home.programs = {
    spotify.enable = true;
    xdg.enable = true;
    shell = {
      fish.enable = true;
      starship.enable = true;
      zoxide.enable = true;
    };
  };

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

  stylix.targets.gtk.enable = lib.mkForce false;
}
