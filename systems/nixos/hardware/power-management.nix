{pkgs, config, ...}: {
  # TLP for advanced power management
  # Note: nixos-hardware Dell Latitude 7420 module handles TLP intelligently
  # Only apply custom settings if TLP is enabled by the hardware module
  services.tlp.settings = if config.services.tlp.enable then {
    # Battery charge thresholds (helps battery longevity)
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
    
    # CPU scaling governor
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    
    # Turbo boost
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;
    
    # Device power management
    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "on";
    
    # USB autosuspend
    USB_AUTOSUSPEND = 1;
  } else {};
  
  # Let nixos-hardware module handle the power-profiles-daemon/TLP conflict
}