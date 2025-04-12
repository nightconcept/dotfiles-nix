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
    sourcegit
    uv
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
    activation.linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      # This script copies .desktop files from the nix profile to a user-writable location
      # It first removes the old directory to ensure deleted apps are removed.
      data = ''
        rm -rf ${config.xdg.dataHome}/nix-desktop-files/applications
        mkdir -p ${config.xdg.dataHome}/nix-desktop-files/applications
        cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/nix-desktop-files/applications/
      '';
    };
  };

  # Ensure XDG Base Directory Specification support is enabled
  xdg.enable = true;

  # Add the directory where we copied the files to the system's data directories
  # Plasma should pick up changes here more readily.
  xdg.systemDirs.data = [ "${config.xdg.dataHome}/nix-desktop-files" ];
}


