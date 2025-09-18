# Main entry point for all NixOS modules
{
  imports = [
    ./kernel
    ./network
    ./network-drives
    ./services/plex
    ./services/vpn-torrent
  ];
}