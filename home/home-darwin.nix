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
    alt-tab-macos
    discord
    karabiner-elements
    obsidian
  ];

  imports = [
    ./programs/common.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/ssh.nix
    ./programs/vscode.nix
    ./programs/wezterm
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/Users/danny";
    stateVersion = "23.11";
  };
}
