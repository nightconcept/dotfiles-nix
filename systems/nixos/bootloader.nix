{config, pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;  # Show last 10 generations
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Plymouth boot splash
  boot.plymouth = {
    enable = true;
    theme = "bgrt";  # Simple theme that shows manufacturer logo if available, otherwise plain
    # Alternative themes: "spinner", "script", "fade-in", "text", "details"
  };
  
  # Ensure quiet boot for cleaner Plymouth experience
  boot.kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
}
