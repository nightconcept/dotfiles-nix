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
    ./programs/common.nix
    ./programs/direnv.nix
    ./programs/git.nix
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
