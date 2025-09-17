{pkgs, ...}: {
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  
  # Bluetooth management service
  services.blueman.enable = true;
  
  # Add bluez utilities
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}