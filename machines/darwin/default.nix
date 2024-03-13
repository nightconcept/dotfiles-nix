{ inputs, pkgs, lib, ... }:
{
  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = [ "danny" ];
    gc = {
      automatic = true;
      user = "danny";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
      '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
      '';
  };

  nixpkgs.config.allowUnfree = true;

  # Use homebrew to install casks and Mac App Store apps
  homebrew = {
    enable = false;
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = false;
    };

    casks = [
      "calibre"
      "eloston-chromium"
      "ferdium"
      "fig"
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
      "visual-studio-code"
      "vlc"
      "wezterm"
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

  system = {
    defaults = {
      finder = {
        FXDefaultSearchScope = "SCcf";
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowStatusBar = true;
      };
    };
    activationScripts.postUserActivation.text = ''
# Following line should allow us to avoid a logout/login cycle
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      launchctl stop com.apple.Dock.agent
      launchctl start com.apple.Dock.agent
      '';
  };

  system.stateVersion = 4;

}