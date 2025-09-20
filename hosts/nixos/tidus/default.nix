# Tidus - Dell Latitude 7420 laptop with Hyprland
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.dell-latitude-7420
    # Include Lix module for this host
    inputs.lix-module.nixosModules.default
  ];

  # Networking
  modules.nixos.networking.base.hostName = "tidus";

    # Desktop environment
    modules.nixos.desktop.hyprland.enable = true;

    # Enable Lix as alternative Nix implementation (tidus only)
    modules.nixos.core.lix.enable = true;
    
    # Hardware features
    modules.nixos.hardware = {
      bluetooth.enable = true;
      power.enable = true;
      sound.enable = true;
      graphics.enable = true;
      usbAutomount.enable = true;
    };
    
    # Storage
    modules.nixos.storage.networkDrives.enable = true;
    
    # Kernel configuration
    modules.nixos.kernel.type = "zen";

    # Programs
    modules.nixos.programs.nomachine.enable = true;

    system.stateVersion = "23.11";
}
