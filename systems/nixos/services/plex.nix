{
  services.netbird.enable = true;
  services.plex = {
    enable = true;
    openFirewall = true;
    user = "danny";
  };
  networking.firewall.allowedTCPPorts = [
    32400
    1900
    5353
    8324
    32410
    32412
    32413
    32414
    32469
  ];
}
