{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./system.nix
    ];

  environment.systemPackages = with pkgs; [
    aldente
    alt-tab-macos
    discord
    hugo
    plex-media-player
    obsidian
  ];
}
