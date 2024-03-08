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
    obsidian
  ];
}
