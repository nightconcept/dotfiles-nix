{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    karabiner-elements
  ];

  imports = [
    ./programs/aerospace.nix
    ./programs/common.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/jankyborders.nix
    ./programs/neovim.nix
    ./programs/ssh.nix
    ./programs/wezterm
    ./programs/zellij.nix
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/Users/danny";
    stateVersion = "23.11";
  };
}
