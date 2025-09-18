{ config, lib, systemType ? "laptop", ... }:
let
  # Check if this is a desktop system (Mac Mini)
  isDesktop = systemType == "desktop";
in
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
      "atlassian-labs/acli"
    ];

    brews = [
      "borders"
      "gettext"
      "pinentry-mac"
      "uv"
      "xz"
    ];

    casks = [
      "calibre"
      "discord"
      "firefox"
      "github"
      "hiddenbar"
      "jellyfin-media-player"
      "mos"
      "nomachine"
      "obsidian"
      "plex"
      "qdirstat"
      "raycast"
      "stretchly"
      "visual-studio-code"
      "vlc"
      "wezterm@nightly"
    ] ++ lib.optionals isDesktop [
      "alt-tab"
      "rectangle"
    ];
  };
}
