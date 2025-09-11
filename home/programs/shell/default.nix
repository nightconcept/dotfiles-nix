{pkgs, ...}: {
  imports = [
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
