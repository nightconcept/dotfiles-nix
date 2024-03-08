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
    mpv
    plex-media-player
    obsidian
  ];
}
