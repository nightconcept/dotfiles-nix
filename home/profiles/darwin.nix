# macOS (desktop) specific configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    karabiner-elements
  ];
}
