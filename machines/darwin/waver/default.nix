{ config, pkgs, lib, ... }:

{

  # System specific packages
  environment.systemPackages = with pkgs; [
    aldente
  ];
}
