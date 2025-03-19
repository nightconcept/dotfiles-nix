{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
    extraOptions = ''
      warn-dirty = false
    '';
  };

  home.packages = with pkgs; [
    btrfs-assistant
    filezilla
    github-desktop
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    obsidian
    pyenv
    vlc
    zoom
  ];

  #xdg.mime.enable = false;

  imports = [
    ./programs/common.nix
    ./programs/direnv.nix
    ./programs/gaming.nix
    ./programs/git.nix
    ./programs/ssh.nix
    ./programs/vscode.nix
    #./programs/wezterm
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };
}
