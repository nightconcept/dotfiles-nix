{ config, lib, pkgs, ... }:

let
  cfg = config.modules.nixos.docker;
in
{
  options.modules.nixos.docker = {
    enable = lib.mkEnableOption "Docker container runtime";

    dockerComposeProjects = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Docker Compose projects to manage";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    users.users.danny.extraGroups = [ "docker" ];

    environment.systemPackages = with pkgs; [
      docker-compose
      lazydocker
    ];
  };
}