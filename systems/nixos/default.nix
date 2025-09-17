{
  imports = [
    ./bootloader.nix
    ./hardware
    ./desktops/plasma6
    ./desktops/hyprland
    ./fonts.nix
    ./locale.nix
    ./network.nix
    ./network-drives.nix
    ./opengl.nix
    ./pkgs
    ./nix.nix
    ./sound.nix
    ./users.nix
    ./secrets/sops.nix
  ];
}
