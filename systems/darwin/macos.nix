{ systemType ? "laptop", ... }:
{
  system = {
    primaryUser = "danny";
    defaults = {
      # Use the default macOS menu bar
      NSGlobalDomain = {
        _HIHideMenuBar = false;
      };
      
      finder = {
        FXDefaultSearchScope = "SCcf";
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowStatusBar = true;
      };

      dock = if systemType == "desktop" then {
        # Desktop dock settings - close to macOS defaults
        autohide = false;
        autohide-delay = 0.5;
        autohide-time-modifier = 0.5;
        show-recents = true;
        static-only = false;
        tilesize = 48;
        magnification = false;
        largesize = 64;
        orientation = "bottom";
        mineffect = "genie";
      } else {
        # Laptop dock settings - minimal and autohide
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        show-recents = false;
        static-only = true;
      };
    };
  };
}
