{
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = ["danny"];
  networking.firewall.allowedTCPPorts = [8211];
}
