{
  config,
  pkgs,
  lib,
  ...
}: 
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) enabled disabled;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "aerith";

  modules.nixos = {
    kernel.type = "lts";
    
    network = {
      networkManager = true;
      mdns = true;
    };
    
    services.plex = {
      enable = true;
      user = "danny";
      openFirewall = true;
    };
  };

  services.openssh.enable = true;

  # System packages for server management
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  system.stateVersion = "23.11";
}
