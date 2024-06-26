{
  config,
  lib,
  pkgs,
  ...
}: {
  # settings from nixos-hardware/common/gpu/amd/default.nix
  options.hardware.amdgpu.loadInInitrd = lib.mkEnableOption (
    lib.mdDoc
    "loading `amdgpu` kernelModule at stage 1. (Add `amdgpu` to `boot.initrd.kernelModules`)"
  ); # default is true for amdgpu hardware
  options.hardware.amdgpu.amdvlk = lib.mkEnableOption (
    lib.mdDoc
    "use amdvlk drivers instead mesa radv drivers"
  );
  options.hardware.amdgpu.opencl = lib.mkEnableOption (
    lib.mdDoc
    "rocm opencl runtime (Install rocmPackages.clr and rocmPackages.clr.icd)"
  ); # default is true for amdgpu hardware

  config = lib.mkMerge [
    {
      services.xserver.videoDrivers = lib.mkDefault ["modesetting"];

      hardware.opengl = {
        driSupport = lib.mkDefault true;
        driSupport32Bit = lib.mkDefault true;
      };
    }
    (lib.mkIf config.hardware.amdgpu.loadInInitrd {
      boot.initrd.kernelModules = ["amdgpu"];
    })
    (lib.mkIf config.hardware.amdgpu.amdvlk {
      hardware.opengl.extraPackages = with pkgs; [
        amdvlk
      ];

      hardware.opengl.extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    })
    (lib.mkIf config.hardware.amdgpu.opencl {
      hardware.opengl.extraPackages =
        if pkgs ? rocmPackages.clr
        then with pkgs.rocmPackages; [clr clr.icd]
        else with pkgs; [rocm-opencl-icd rocm-opencl-runtime];
    })
  ];
}
