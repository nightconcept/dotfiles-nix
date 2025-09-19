# Hardware configuration for Vincent
# Adjust based on your actual VM specifications
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # File systems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/CHANGE_ME";  # Update with actual UUID
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CHANGE_ME";  # Update with actual UUID
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Swap (optional, adjust size as needed)
  swapDevices = [
    { device = "/dev/disk/by-uuid/CHANGE_ME"; }  # Update if using swap
  ];

  # Hardware settings
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # VM guest additions
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}