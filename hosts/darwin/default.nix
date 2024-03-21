{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./users.nix
  ];

  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = ["danny"];
    gc = {
      automatic = true;
      user = "danny";
      options = "--delete-older-than 7d";
    };
    extraOptions =
      ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      ''
      + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
  };

  nixpkgs.config.allowUnfree = true;

  # Use homebrew to install casks and Mac App Store apps
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    casks = [
      "calibre"
      "eloston-chromium"
      "ferdium"
      "firefox"
      "github"
      "hiddenbar"
      "libreoffice"
      "mos"
      "nomachine"
      "notunes"
      "plex"
      "raycast"
      "rectangle"
      "spotify"
      "stretchly"
      "the-unarchiver"
      "typora"
      "vlc"
      "zoom"
    ];
  };

  services.nix-daemon.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
  };

  environment.systemPackages = with pkgs; [
    bat
    btop
    curl
    gcc
    gh
    git
    home-manager
    wget
    vim
    wget
    zsh
  ];

  fonts = {
    fonts = with pkgs; [
      (
        nerdfonts.override
        {
          fonts = [
            "DroidSansMono"
            "FiraCode"
            "FiraMono"
            "Hack"
            "Inconsolata"
            "Noto"
            "SourceCodePro"
            "Ubuntu"
          ];
        }
      )
    ];
  };

  system = {
    defaults = {
      finder = {
        FXDefaultSearchScope = "SCcf";
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowStatusBar = true;
      };
    };
  };

  system.stateVersion = 4;
}
