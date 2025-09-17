{pkgs, ...}: {
  imports = [
    ./starship.nix
    ./zoxide.nix
    ./fish.nix
  ];
}
