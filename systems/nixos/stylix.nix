{
  config,
  lib,
  pkgs,
  ...
}: {
  stylix = {
    wallpaper = config.lib.stylix.mkAnimation {
      animation = ../../home/desktops/hyprland/main.jpg;
      polarity = "dark";
    };
  };
}
