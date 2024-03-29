{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./bootloader.nix
    ./hardware
    ./desktops/hyprland
    ./fonts.nix
    ./locale.nix
    ./network.nix
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
