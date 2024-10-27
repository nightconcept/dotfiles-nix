{
  config,
  pkgs,
  lib,
  ...
}: {
  options.plasma6 = {
    enable = lib.mkEnableOption "Enables KDE Plasma 6 desktop environment";
  };

  config = lib.mkIf config.plasma6.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
