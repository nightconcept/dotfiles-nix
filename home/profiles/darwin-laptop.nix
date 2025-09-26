# macOS laptop-specific configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./darwin-desktop.nix
    ../desktops/aerospace
  ];

  modules.home.programs = {
    shell = {
      fish.enable = true;
      starship.enable = true;
      zoxide.enable = true;
    };
  };

  desktops.aerospace.enable = true;
}
