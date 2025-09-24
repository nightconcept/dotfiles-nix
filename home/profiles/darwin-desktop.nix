# macOS (desktop) specific configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./base.nix
    ../../modules/home
  ];

  modules.home.programs = {
    shell = {
      fish.enable = true;
      starship.enable = true;
      zoxide.enable = true;
    };
  };

  homebrew = {
    casks = [
      "gitnuro"
    ];
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    karabiner-elements
  ];
}
