{config, pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;  # Show last 10 generations
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Enable systemd in initrd for better Plymouth integration with LUKS
  boot.initrd.systemd.enable = true;
  
  # Plymouth boot splash
  boot.plymouth = {
    enable = true;
    theme = "bgrt";  # Simple theme that shows manufacturer logo if available, otherwise plain
    # Alternative themes: "spinner", "script", "fade-in", "text", "details"
  };
  
  # Kernel parameters for Plymouth with LUKS
  # Note: Remove "splash" if graphical password prompt doesn't appear
  boot.kernelParams = [ 
    "quiet" 
    "splash"  # Comment out this line if password prompt is delayed
    "loglevel=3" 
    "rd.systemd.show_status=false" 
    "rd.udev.log_level=3" 
    "udev.log_priority=3" 
    "plymouth.ignore-serial-consoles"  # Helps with password prompt visibility
  ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
}
