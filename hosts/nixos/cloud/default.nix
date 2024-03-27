{
  config,
  pkgs,
  inputs,
  options,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    (import ../../../systems/nixos/disko.nix
      {device = "/dev/nvme0n1";})
    ../../../systems/nixos/desktops/hyprland
    ../../../systems/nixos/wireless.nix
    ../options.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_7;

  networking.hostName = "cloud";

  options.host.monitor.count = 1;

  services.xserver = {
    displayManager.gdm.enable = true;
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  environment.systemPackages = with pkgs; [
    acpi
    firefox
    powertop
    networkmanagerapplet
  ];

  # Do not touch
  system.stateVersion = "23.11";
}
