{
  config,
  pkgs,
  lib,
  ...
}: {
  options.plasma5 = {
    enable = lib.mkEnableOption "Enables plasma5 desktop environment";
  };

  config = lib.mkIf config.plasma5.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
  };
}
