{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./amd-gpu.nix
    #./amd-pstate.nix
  ];

  services.printing.enable = true;

  # Automount USB drives
  services.udev.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem",
    RUN{program} += "${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media
  '';
}
