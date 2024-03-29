{
  config,
  pkgs,
  lib,
  ...
}: {
  options.hyprland = {
    enable = lib.mkEnableOption "Enables hyprland desktop environment";
  };

  config = lib.mkIf config.hyprland.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # used in various UIs and backends for hyprland
    services = {
      gvfs.enable = true;
    };

    # sessionVariables to set for wayland
    # cannot be set in homeManager because sessionVariables there on wayland sessions
    # do not work
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";

      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";

      WLR_RENDERER = "vulkan";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
