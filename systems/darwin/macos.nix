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

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        show-recents = false;
        static-only = true;
      };
    };
  };
}
