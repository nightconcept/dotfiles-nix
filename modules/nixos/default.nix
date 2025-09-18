# Main entry point for all NixOS modules
{
  imports = [
    ./kernel
    ./network
    ./services/plex
  ];
}