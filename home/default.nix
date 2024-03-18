{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig.enable = true;

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
