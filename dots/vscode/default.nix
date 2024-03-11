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
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
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