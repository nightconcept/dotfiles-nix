{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  programs.starship = {
    enable = true;
    # Use external TOML configuration file from shared directory
    # This allows the same config to be used across Nix, non-Nix, and Windows systems
    settings = builtins.fromTOML (builtins.readFile ../../../shared/starship.toml);
  };
}