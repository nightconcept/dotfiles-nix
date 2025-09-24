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
    firefox.enable = false;  # Disabled to avoid conflicts with existing Firefox profile
    spotify.enable = true;
    wezterm.configOnly = true;
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
    gitnuro
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
