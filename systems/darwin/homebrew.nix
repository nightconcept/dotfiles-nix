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
      "elixir"
      "pyenv"
      "xz"
    ];

    casks = [
      "calibre"
      "eloston-chromium"
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
      "stretchly"
      "vlc"
      "wezterm@nightly"
      "zoom"
    ];
  };
}
