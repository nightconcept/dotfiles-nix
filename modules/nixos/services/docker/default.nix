# Docker container service module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.nixos.services.docker;
in
{
  options.modules.nixos.services.docker = {
    enable = mkEnableOption "Docker container service";
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    users.users.danny.extraGroups = [ "docker" ];
  };
}