{ inputs, pkgs, lib, ... }:
{
  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
      ];
      userSettings = {
        "workbench.colorTheme" = "Solarized Osaka";
        "editor.fontFamily" = "'FiraMono Nerd Font', 'monospace', monospace";
        "editor.fontSize" = 16;
        "editor.fontLigatures" = false;
      };
    };
  };
}