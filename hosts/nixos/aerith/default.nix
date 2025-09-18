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

  # Override bootloader for legacy BIOS (no EFI partition)
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      enable = true;
      device = "/dev/sda";  # Install GRUB to MBR
    };
  };

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
