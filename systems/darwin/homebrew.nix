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
      "calibre"
      "eloston-chromium"
      "ferdium"
      "firefox"
      "github"
      "hiddenbar"
      "mos"
      "nomachine"
      "notunes"
      "plex"
      "raycast"
      "rectangle"
      "spotify"
      "stretchly"
      "vlc"
      "zoom"
    ];
  };
}
