{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./dunst
    ./git.nix
    ./hypr
    ./rofi
    ./waybar
    ./wlogout
  ];
}
