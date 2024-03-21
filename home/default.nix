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
    inputs.nix-colors.homeManagerModules.default
    ./desktops/hyprland
    ./programs
  ];

  config.colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-terminal-dark;

  home = {
    username = "danny";
    homeDirectory = "/home/danny";
    stateVersion = "23.11";
  };

  news = {
    display = "silent";
  };
}
