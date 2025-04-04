{
  inputs,
  pkgs,
  lib,
  ...
}: {
  programs = {
    vscode = {
      enable = true;
      mutableExtensionsDir = false;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.vscode-extensions;
          [
            yzhang.markdown-all-in-one
            bbenoist.nix
            eamodio.gitlens
            kamikillerto.vscode-colorize
            pkief.material-icon-theme
            ms-python.python
            ms-vscode-remote.remote-ssh-edit
            svelte.svelte-vscode
            elixir-lsp.vscode-elixir-ls
            ms-vscode-remote.remote-wsl
            tamasfe.even-better-toml
            esbenp.prettier-vscode
            bradlc.vscode-tailwindcss
            styled-components.vscode-styled-components
            davidanson.vscode-markdownlint
            shd101wyy.markdown-preview-enhanced
            yoavbls.pretty-ts-errors
            astro-build.astro-vscode
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
              name = "remote-explorer";
              publisher = "ms-vscode";
              version = "0.5.2024081309";
              sha256 = "sha256-YExf9Yyo7Zp0Nfoap8Vvtas11W9Czslt55X9lb/Ri3s=";
            }
            {
              name = "remote-ssh";
              publisher = "ms-vscode-remote";
              version = "0.116.2024100715";
              sha256 = "sha256-Mo11BGA27Bi62JRPU6INOq3SXTsp5ASYzd8ihlV3ZZY=";
            }
            {
              name = "geminicodeassist";
              publisher = "google";
              version = "2.30.1";
              sha256 = "sha256-CixHqIUgTju8GnH2gwdgYb4UfJ/2Jx8lH5oHzsXqZYk=";
            }
            {
              name = "roo-cline";
              publisher = "rooveterinaryinc";
              version = "3.11.4";
              sha256 = "sha256-7F94p5ebaLrcbqGhvEgaSmnffi1KbG1LNmBMSp2H69Q=";
            }
          ];
        userSettings = {
          "chat.commandCenter.enabled" = false;
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
          "git.confirmSync" = false;
          "git.defaultBranchName" = "main";
          "gitlens.showWhatsNewAfterUpgrades" = false;
          "svelte.enable-ts-plugin" = true;
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
  };
}
