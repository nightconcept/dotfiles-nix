{
  config,
  pkgs,
  inputs,
  ...
}: {
  networking.networkmanager.enable = true;

  # Network mounts
  # TODO: Relies on <SERVER>-secrets in /etc/nixos for now, change it later
  # Source: https://nixos.wiki/wiki/Samba#CIFS_mount_configuration
  fileSystems."/mnt/gawain" = {
    device = "//terra/gawain";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
    in ["${automount_opts},credentials=/etc/nixos/terra-secrets,uid=1000,gid=100"];
  };

  fileSystems."/mnt/lancelot" = {
    device = "//terra/lancelot";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
    in ["${automount_opts},credentials=/etc/nixos/terra-secrets,uid=1000,gid=100"];
  };

  fileSystems."/mnt/titan" = {
    device = "//mog/titan";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
    in ["${automount_opts},credentials=/etc/nixos/mog-secrets,uid=1000,gid=100"];
  };
}
