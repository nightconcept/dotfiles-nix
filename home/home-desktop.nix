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
    github-desktop
    kdePackages.xdg-desktop-portal-kde
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    obsidian
    tlp
    uv
    vlc
    vscode
    xdg-utils
  ];

  imports = [
    ./programs/common.nix
    ./programs/direnv.nix
    ./programs/gaming.nix
    ./programs/git.nix
    ./programs/ssh.nix
    #./programs/wezterm
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };

  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true; # Make sure home-manager manages mime apps

    # Set GitHub Desktop as the default handler for its specific auth scheme
    defaultApplications = {
      "x-scheme-handler/x-github-desktop-dev-auth" = "github-desktop.desktop";

      # You can add other associations here if needed, for example:
      # "text/html" = "firefox.desktop"; [1, 5]
    };
  };
}
