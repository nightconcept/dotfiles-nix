{
  config,
  lib,
  pkgs,
  ...
}: {
  stylix = {
    image = ../../wallpaper/main.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
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
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };
    targets = {
      gnome.enable = true;
      gtk.enable = true;
      waybar.enableLeftBackColors = false;
      waybar.enableRightBackColors = false;
    };
  };
}
