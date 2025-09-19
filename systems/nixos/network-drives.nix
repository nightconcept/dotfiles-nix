{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Network mounts
  # Using sops-managed credentials for secure storage
  # Source: https://nixos.wiki/wiki/Samba#CIFS_mount_configuration
  
  # Create mount point
  systemd.tmpfiles.rules = [
    "d /mnt/titan 0755 root root -"
  ];
  
  # Use systemd mount units directly to avoid rebuild issues
  systemd.mounts = [{
    description = "Mount titan network share";
    what = "//192.168.1.167/titan";  # Using fixed IP address for reliability
    where = "/mnt/titan";
    type = "cifs";
    options = "credentials=/run/secrets/network/titan_credentials,uid=1000,gid=100,iocharset=utf8,nofail,_netdev,x-systemd.automount,x-systemd.mount-timeout=10";
    wantedBy = [ ];  # Don't auto-start, let automount handle it
    after = [ "network-online.target" "nss-lookup.target" ];
    wants = [ "network-online.target" ];
    requiredBy = [ ];  # Don't fail the boot if mount fails
  }];
  
  # Create automount unit for on-demand mounting
  systemd.automounts = [{
    description = "Automount titan network share";
    where = "/mnt/titan";
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "60";
      DirectoryMode = "0755";
    };
  }];
}
