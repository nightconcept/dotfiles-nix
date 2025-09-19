# User configuration module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.nixos.core.users;
in
{
  options.modules.nixos.core.users = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable user configuration";
    };

    primaryUser = mkOption {
      type = types.str;
      default = "danny";
      description = "Primary user name";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.primaryUser} = {
      isNormalUser = true;
      description = "Danny";
      extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "video" "audio" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        # Add any default public keys here if needed
      ];
    };

    programs.fish.enable = true;
  };
}