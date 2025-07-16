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
      "mise"
      "pinentry-mac"
      "uv"
      "ruby"
      "xz"
    ];

    casks = [
      "alt-tab"
      "calibre"
      "cursor"
      "discord"
      "firefox"
      "gemini-cli"
      "github"
      "hiddenbar"
      "love"
      "mos"
      "nomachine"
      "obsidian"
      "plex"
      "raycast"
      "rectangle"
      "stretchly"
      "visual-studio-code"
      "vlc"
      "wezterm@nightly"
      "windsurf"
      "zed"
    ];
  };
}
