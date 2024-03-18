{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./dunst
    ./hyprland
    ./rofi
    ./waybar
    ./wlogout
  ];

  config = {
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };

    home.packages = with pkgs; [
      wl-clipboard

      xfce.thunar
    ];
  };
}
