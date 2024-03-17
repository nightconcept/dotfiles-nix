{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d73a450a-16b5-4f71-956e-95c1a697dc93";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/659B-6A76";
      fsType = "vfat";
    };

  fileSystems."/media/storage0" =
    { device = "/dev/disk/by-uuid/2A20B13B20B10F37";
      fsType = "ntfs";
    };

  fileSystems."/media/storage1" =
    { device = "/dev/disk/by-uuid/6A60020A6001DDA7";
      fsType = "ntfs";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/1d41f8de-d6f3-4f4d-b462-a63575b71f05"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
