{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    delta
    duf
    eza
    fd
    fzf
    ncdu
    neovim
    nmap
    rsync
    speedtest-cli
    tmux
    trash-cli
    wget
    zip
    zoxide

    alt-tab-macos
    discord
    karabiner-elements
    mpv
    obsidian
  ];

  imports = [
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/vscode
    ./programs/wezterm
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/Users/danny";
    stateVersion = "23.11";
  };
}
