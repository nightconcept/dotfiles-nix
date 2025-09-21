# Network drives (CIFS/SMB) configuration module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.nixos.storage.networkDrives;
in
{
  options.modules.nixos.storage.networkDrives = {
    enable = mkEnableOption "Network drive mounting";

    mounts = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Mount point name";
          };
          source = mkOption {
            type = types.str;
            description = "Network share path (e.g., //192.168.1.167/share)";
          };
          credentials = mkOption {
            type = types.str;
            default = null;
            description = "Path to credentials file";
          };
        };
      });
      default = [];  # Don't set defaults here, let the host configure it
      description = "Network mounts to configure";
    };
  };

  config = mkIf cfg.enable {
    # Create mount points
    systemd.tmpfiles.rules = map (mount: 
      "d /mnt/${mount.name} 0755 root root -"
    ) cfg.mounts;
    
    # Create mount units
    systemd.mounts = map (mount: {
      description = "Mount ${mount.name} network share";
      what = mount.source;
      where = "/mnt/${mount.name}";
      type = "cifs";
      options = "credentials=${mount.credentials},uid=1000,gid=100,iocharset=utf8,nofail,_netdev,x-systemd.automount,x-systemd.mount-timeout=10";
      wantedBy = [ ];
      after = [ "network-online.target" "nss-lookup.target" ];
      wants = [ "network-online.target" ];
      requiredBy = [ ];
    }) cfg.mounts;
    
    # Create automount units
    systemd.automounts = map (mount: {
      description = "Automount ${mount.name} network share";
      where = "/mnt/${mount.name}";
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "60";
        DirectoryMode = "0755";
      };
    }) cfg.mounts;
  };
}