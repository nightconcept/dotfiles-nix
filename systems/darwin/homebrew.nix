{
  # Use homebrew to install casks and Mac App Store apps
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "gettext"
      "pinentry-mac"
      "pyenv"
      "xz"
    ];

    casks = [
      "calibre"
      "firefox"
      "github"
      "hiddenbar"
      "mos"
      "nomachine"
      "notunes"
      "obsidian"
      "plex"
      "raycast"
      "rectangle"
      "sourcetree"
      "stretchly"
      "vlc"
      "wezterm@nightly"
      "zoom"
    ];
  };
}
