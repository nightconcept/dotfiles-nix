{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  programs = {
    home-manager.enable = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  imports = [
    inputs.nix-colors.homeManagerModules.default
    ./desktops/hyprland
    ./programs
  ];

  # config = {
  #   my.settings = {
  #     default = {
  #       shell = "zsh";
  #       terminal = "wezterm";
  #       browser = "firefox";
  #       editor = "code";
  #     };
  #     fonts.monospace = "FiraCode Nerd Font Mono";
  #   };

  colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-terminal-dark;
  # };

  #config.colorScheme = inputs.nix-colors.colorSchemes.tokyo-night-terminal-dark;

  home = {
    username = "danny";
    homeDirectory = "/home/danny";
    stateVersion = "23.11";
  };

  news = {
    display = "silent";
  };
}
