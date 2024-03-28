{
  config,
  lib,
  pkgs,
  stylix,
  ...
}: {
  stylix = {
    wallpaper = config.lib.stylix.mkAnimation {
      animation = ../../desktops/main.jpg;
      polarity = "dark";
    };
    fonts = {
      serif = {
        package = pkgs.nerdfonts;
        name = "Fira Sans Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerdfonts;
        name = "Fira Sans Nerd Font";
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "FiraCode Nerd Font";
      };
      sizes = {
        desktop = 12;
        applications = 15;
        terminal = 15;
        popups = 12;
      };
    };
    opacity = {
      terminal = 0.97;
      applications = 0.99;
      popups = 0.50;
      desktop = 0.95;
    };
    targets = {
      waybar.enableLeftBackColors = true;
      waybar.enableRightBackColors = true;
    };
  };
}
