{
  inputs,
  lib,
  pkgs,
  ...
}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    karabiner-elements
  ];

  imports = [
    ./common.nix
    ./programs/aerospace.nix
    ./programs/common.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/jankyborders.nix
    ./programs/neovim.nix
    ./programs/shell
    ./programs/ssh.nix
    ./programs/wezterm
    ./programs/zellij.nix
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/Users/danny";
    stateVersion = "23.11";
  };
}
