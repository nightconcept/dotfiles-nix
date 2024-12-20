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
    fastfetch
    ferdium
    filezilla
    fira
    fira-go
    fira-code-symbols
    github-desktop
    nerdfonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    obsidian
    pyenv
    source-serif
    vlc
    work-sans
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
