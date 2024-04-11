{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    plasma5.enable = true;
    wireless.enable = true;

    networking.hostName = "cloud";

    boot.kernelPackages = pkgs.linuxPackages_6_7;

    # host-specific packages
    environment.systemPackages = with pkgs; [
      acpi
      powertop
      networkmanagerapplet
    ];

    system.stateVersion = "23.11";
  };
}
