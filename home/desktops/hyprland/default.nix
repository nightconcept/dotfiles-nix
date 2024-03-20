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
      brightnessctl
      grimblast
      gvfs
      pamixer
      wl-clipboard
      # Thunar is very needy and needs all of these and gvfs to get it's full functional powers
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      xfce.thunar-volman
      xfce.tumbler
      xfce.xfconf
    ];
  };
}
