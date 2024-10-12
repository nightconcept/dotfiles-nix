{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs = {
    vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions;
        [
          yzhang.markdown-all-in-one
          bbenoist.nix
          eamodio.gitlens
          kamikillerto.vscode-colorize
          pkief.material-icon-theme
          ms-python.python
          vscode-extensions.ms-vscode-remote.remote-ssh
          vscode-extensions.ms-vscode-remote.remote-ssh-edit
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "where-am-i";
            publisher = "antfu";
            version = "0.2.0";
            sha256 = "sha256-M9TCILD6KKLHCDBP0mBR5soeYb2MFuBAmyKPlKbl1tg=";
          }
          {
            name = "tokyo-night-henrikvilhelmberglund";
            publisher = "henrikvilhelmberglund";
            version = "1.1.0";
            sha256 = "sha256-WEdmyIwmJ2uigNhksgzr6IH4PIWwthJvX5N1OG3JUZ4=";
          }
          {
            name = "ms-vscode.remote-explorer";
            publisher = "Microsoft";
            version = " 	0.5.2024081309";
            sha256 = "sha256-WEdmyIwmJ2uigNhksgzr6IH4PIWwthJvX5N1OG3JUZ4=";
          }
        ];
      userSettings = {
        "colorize.languages" = [
            "nix"
            "rasi"
        ];
        "editor.accessibilitySupport" = "off";
        "editor.guides.bracketPairs" = true;
        "editor.fontFamily" = "'FiraCode Nerd Font', Consolas, Meslo, 'monospace', monospace";
        "editor.fontSize" = 16;
        "editor.fontLigatures" = true;
        "editor.rulers" = [
          {
            "color" = "#808080";
            "column" = 100;
          }
        ];
        "editor.tabSize" = 2;
        "editor.wordWrap" = "on";
        "extensions.ignoreRecommendations" = true;
        "git.autofetch" = true;
        "git.defaultBranchName" = "main";
        "gitlens.showWelcomeOnInstall" = false;
        "gitlens.showWhatsNewAfterUpgrades" = false;
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.fontSize" = 14;
        "update.mode" = "none";
        "window.zoomLevel" = 1;
        "workbench.colorTheme" = "Tokyo Night";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "none";
      };
    };
  };
}
