{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  programs.starship = {
    enable = true;
    # Use external TOML configuration file
    # This allows the same config to be used across Nix and non-Nix systems
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}