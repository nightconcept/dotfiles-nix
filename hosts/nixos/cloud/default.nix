{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.default
    (import ../../../systems/nixos/disko.nix
      {device = "/dev/nvme0n1";})
    ../../../systems/nixos/desktops/hyprland
    ../../../systems/nixos/wireless.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_7;

  networking.hostName = "cloud";

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
