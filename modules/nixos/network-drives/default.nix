{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  cfg = config.modules.nixos.network-drives;

  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt mkOpt enabled disabled;
in
{
  options.modules.nixos.network-drives = {
    titan = {
      enable = mkBoolOpt false "Enable titan network drive mount";

      server = mkOpt lib.types.str "192.168.1.167" "IP address or hostname of the titan server";

      shareName = mkOpt lib.types.str "titan" "Name of the network share";

      mountPoint = mkOpt lib.types.str "/mnt/titan" "Local mount point for the titan share";

      credentialsFile = mkOpt lib.types.str "/etc/sops-mog-secrets" "Path to credentials file for authentication";

      uid = mkOpt lib.types.int 1000 "User ID for mounted files";

      gid = mkOpt lib.types.int 100 "Group ID for mounted files";

      autoMount = mkBoolOpt true "Enable automount for on-demand mounting";

      idleTimeout = mkOpt lib.types.int 60 "Timeout in seconds before unmounting when idle (for automount)";
    };
  };

  config = mkIf cfg.titan.enable {
    # Create mount point
    systemd.tmpfiles.rules = [
      "d ${cfg.titan.mountPoint} 0755 root root -"
    ];

    # Use systemd mount units directly to avoid rebuild issues
    systemd.mounts = [{
      description = "Mount titan network share";
      what = "//${cfg.titan.server}/${cfg.titan.shareName}";
      where = cfg.titan.mountPoint;
      type = "cifs";
      options = "credentials=${cfg.titan.credentialsFile},uid=${toString cfg.titan.uid},gid=${toString cfg.titan.gid},iocharset=utf8,nofail,_netdev,x-systemd.automount,x-systemd.mount-timeout=10";
      wantedBy = [ ];  # Don't auto-start, let automount handle it
      after = [ "network-online.target" "nss-lookup.target" ];
      wants = [ "network-online.target" ];
      requiredBy = [ ];  # Don't fail the boot if mount fails
    }];

    # Create automount unit for on-demand mounting
    systemd.automounts = mkIf cfg.titan.autoMount [{
      description = "Automount titan network share";
      where = cfg.titan.mountPoint;
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = toString cfg.titan.idleTimeout;
        DirectoryMode = "0755";
      };
    }];
  };
}