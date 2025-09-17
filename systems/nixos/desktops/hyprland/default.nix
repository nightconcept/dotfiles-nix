{
  config,
  pkgs,
  lib,
  ...
}: {
  options.hyprland = {
    enable = lib.mkEnableOption "Enables Hyprland Wayland compositor";
  };

  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    
    services.displayManager.autoLogin = {
      enable = true;
      user = "danny";
    };

    # Enable portal for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # Hyprland-specific packages
    environment.systemPackages = with pkgs; [
      waybar
      wofi
      mako
      swaylock-fancy
      swayidle
      wlogout
      swaybg
      grimblast
      wl-clipboard
      brightnessctl
      pamixer
      playerctl
      networkmanagerapplet
      pavucontrol
      kdePackages.polkit-kde-agent-1
      
      # Python packages for waybar scripts
      python3
      python3Packages.pygobject3
      python3Packages.dbus-python
      gobject-introspection
      libsForQt5.qt5.qtwayland
      qt6.qtwayland
      wob
    ];

    # Enable services needed for Hyprland
    services.dbus.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Security settings for swaylock
    security.pam.services.swaylock = {};

    # Environment variables for Hyprland
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };
}