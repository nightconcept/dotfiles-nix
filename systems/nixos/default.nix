{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./bootloader.nix
    ./hardware.nix
    ./desktops/hyprland
    ./fonts.nix
    ./locale.nix
    ./network-drives.nix
    ./opengl.nix
    ./persist.nix
    ./pkgs.nix
    ./nix.nix
    ./sound.nix
    ./users.nix
    ./wireless.nix
  ];
}
