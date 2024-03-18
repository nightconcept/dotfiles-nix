{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./config.lua;
  };
}
