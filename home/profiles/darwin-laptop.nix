# macOS laptop-specific configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./darwin.nix
    ../programs/aerospace.nix
    ../programs/jankyborders.nix
  ];

  # macOS laptops use shell instead of zsh
  # (included via default.nix based on hostname)
}