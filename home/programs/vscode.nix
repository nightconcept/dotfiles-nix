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
            kamikillerto.vscode-colorize
            pkief.material-icon-theme
            ms-python.python
            ms-vscode-remote.remote-ssh-edit
            svelte.svelte-vscode
            elixir-lsp.vscode-elixir-ls
            ms-vscode-remote.remote-wsl
            tamasfe.even-better-toml
            styled-components.vscode-styled-components
            davidanson.vscode-markdownlint
            shd101wyy.markdown-preview-enhanced
            yoavbls.pretty-ts-errors
            astro-build.astro-vscode
            bradlc.vscode-tailwindcss
            editorconfig.editorconfig
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
              version = "0.5.2025021709";
              sha256 = "sha256-tCNkC7qa59oL9TXA+OKN0Tq5wl0TOLJhHpiKRLmMlgo=";
            }
            {
              name = "remote-ssh";
              publisher = "ms-vscode-remote";
              version = "0.120.2025040915";
              sha256 = "sha256-XW7BiUtqFH758I5DDRU2NPdESJC6RfTDAuUA4myY734=";
            }
            {
              name = "roo-cline";
              publisher = "rooveterinaryinc";
              version = "3.16.1";
              sha256 = "sha256-woLK05nyX9yajVN40wsCfyTCpXdhDLHoe/EkodNKI4c=";
            }
            {
              name = "geminicodeassist";
              publisher = "google";
              version = "2.31.0";
              sha256 = "sha256-sKN/f6DWkA2MjtuDV3zCMrLc+bQd9tdBffoJIowijiw=";
            }
            {
              name = "lua";
              publisher = "sumneko";
              version = "3.14.0";
              sha256 = "sha256-auXQudzWRbq/cXMpFkheqHhJMu7XwacdsaZYAkv1pQs=";
            }
            {
              name = "second-local-lua-debugger-vscode";
              publisher = "ismoh-games";
              version = "0.3.8";
              sha256 = "sha256-xuOIBBnVWNREAAkAXkdSEsdqM49g+ngmNKtgJWrATNA=";
            }
            {
              name = "stylua";
              publisher = "johnnymorganz";
              version = "1.7.1";
              sha256 = "sha256-AbMCYYyK6Ywm/VljzAdmjk0VWm7JRH5GgJAC38T3j/c=";
            }
            {
              name = "pixelbyte-love2d";
              publisher = "pixelbyte-studios";
              version = "0.1.26";
              sha256 = "sha256-Q46UqYW9Ce4kHxknOf65/vx3GmWx/eP+8BrHoLxIC2c=";
            }
            {
              name = "github-local-actions";
              publisher = "sanjulaganepola";
              version = "1.2.5";
              sha256 = "sha256-gc3iOB/ibu4YBRdeyE6nmG72RbAsV0WIhiD8x2HNCfY=";
            }
            {
              name = "shader";
              publisher = "slevesque";
              version = "1.1.5";
              sha256 = "sha256-Pf37FeQMNlv74f7LMz9+CKscF6UjTZ7ZpcaZFKtX2ZM=";
            }
            {
              name = "luahelper";
              publisher = "yinfei";
              version = "0.2.29";
              sha256 = "sha256-/2RTIl3avuQb0DRciUwDYyJ/vfHjtGWyxSuB8ssYZuo=";
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
          "githubLocalActions.dockerDesktopPath" = "/Applications/Docker.app";
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
