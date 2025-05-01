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
      "alt-tab"
      "calibre"
      "cursor"
      "discord"
      "firefox"
      "github"
      "hiddenbar"
      "love"
      "microsoft-teams"
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
      "windsurf"
      "zoom"
    ];
  };
}
