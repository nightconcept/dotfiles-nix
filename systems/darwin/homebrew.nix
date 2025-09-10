{
  # Use homebrew to install casks and Mac App Store apps
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "FelixKratz/formulae"
    ];

    brews = [
      "acli"
      "borders"
      "gettext"
      "pinentry-mac"
      "uv"
      "xz"
      "zellij"
    ];

    casks = [
      "calibre"
      "discord"
      "firefox"
      "github"
      "hiddenbar"
      "mos"
      "nomachine"
      "obsidian"
      "plex"
      "raycast"
      "stretchly"
      "visual-studio-code"
      "vlc"
      "wezterm@nightly"
    ];
  };
}
