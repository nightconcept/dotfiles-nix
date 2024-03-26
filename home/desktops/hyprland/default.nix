{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./dunst
    ./hypr
    ./kanshi.nix
    ./rofi
    ./theme
    ./waybar
    ./wlogout
  ];

  config = {
    home.packages = with pkgs; [
      brightnessctl
      grimblast
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
