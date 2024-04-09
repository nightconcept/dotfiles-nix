{
  # Use homebrew to install casks and Mac App Store apps
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    casks = [
      "beeper"
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
      "typora"
      "vial"
      "vlc"
      "zoom"
    ];
  };
}
