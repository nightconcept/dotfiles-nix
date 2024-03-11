{ inputs, pkgs, lib, ... }:
{
  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        yzhang.markdown-all-in-one
        bbenoist.nix
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "solarized-osaka";
        publisher = "sherloach";
        version = "0.1.1";
        sha256 = "sha256-HYkzht8jPYBwE3bHHvyU4amNYunsfayPTWBiBVyY+1g=";
      }
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