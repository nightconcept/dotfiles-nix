{
  config,
  pkgs,
  inputs,
  ...
}: {
  networking.networkmanager = {
    enable = true;
  };

  # Enable mDNS for .local domain resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Static host entry for mog server
  networking.hosts = {
    "192.168.1.100" = [ "mog" "mog.local" ];
  };
}
