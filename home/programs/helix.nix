{ config, lib, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    
    settings = {
      theme = lib.mkForce "tokyonight_transparent";
      
      editor = {
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        
        line-number = "relative";
        cursorline = true;
        auto-completion = true;
        auto-format = true;
        auto-save = false;
        idle-timeout = 1;
        completion-trigger-len = 2;
        true-color = true;
        rulers = [ 80 120 ];
        bufferline = "multiple";
        color-modes = true;
        
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        
        statusline = {
          left = [ "mode" "spinner" "file-name" "file-modification-indicator" ];
          center = [ "diagnostics" ];
          right = [ "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
        };
        
        indent-guides = {
          render = true;
          character = "┊";
        };
      };
      
      keys.normal = {
        space = {
          space = "file_picker";
          w = ":w";
          q = ":q";
          x = ":wq";
        };
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
      
      keys.insert = {
        j.k = "normal_mode";
      };
    };
    
    languages = {
      language-server = {
        # Nix
        nil = {
          command = "${pkgs.nil}/bin/nil";
        };
        
        # Rust
        rust-analyzer = {
          command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          config = {
            checkOnSave.command = "clippy";
            cargo.features = "all";
          };
        };
        
        # TypeScript/JavaScript
        typescript-language-server = {
          command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
          args = [ "--stdio" ];
          config = {
            tsserver = {
              path = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";
            };
          };
        };
        
        # Python
        pylsp = {
          command = "${pkgs.python3Packages.python-lsp-server}/bin/pylsp";
          config = {
            pylsp = {
              plugins = {
                pycodestyle = { enabled = false; };
                pyflakes = { enabled = true; };
                pylint = { enabled = false; };
                black = { enabled = true; };
                isort = { enabled = true; };
                mypy = { enabled = true; };
              };
            };
          };
        };
        
        # YAML
        yaml-language-server = {
          command = "${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server";
          args = [ "--stdio" ];
          config = {
            yaml = {
              format = { enable = true; };
              validation = true;
              schemaStore = { enable = true; };
            };
          };
        };
        
        # Markdown
        marksman = {
          command = "${pkgs.marksman}/bin/marksman";
          args = [ "server" ];
        };
        
        # TOML
        taplo = {
          command = "${pkgs.taplo}/bin/taplo";
          args = [ "lsp" "stdio" ];
        };
        
        # C/C++
        clangd = {
          command = "${pkgs.clang-tools}/bin/clangd";
          args = [ "--background-index" "--clang-tidy" "--completion-style=detailed" ];
        };
        
        # C#
        omnisharp = {
          command = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";
          args = [ "-lsp" ];
        };
        
        # Lua
        lua-language-server = {
          command = "${pkgs.lua-language-server}/bin/lua-language-server";
        };
      };
      
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
          };
          language-servers = [ "nil" ];
        }
        {
          name = "rust";
          auto-format = true;
          formatter = {
            command = "${pkgs.rustfmt}/bin/rustfmt";
            args = [ "--edition" "2021" ];
          };
          language-servers = [ "rust-analyzer" ];
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [ "--parser" "typescript" ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [ "--parser" "javascript" ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "jsx";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [ "--parser" "javascript" ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "tsx";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [ "--parser" "typescript" ];
          };
          language-servers = [ "typescript-language-server" ];
        }
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = "${pkgs.black}/bin/black";
            args = [ "-" "--quiet" "--line-length" "88" ];
          };
          language-servers = [ "pylsp" ];
        }
        {
          name = "yaml";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [ "--parser" "yaml" ];
          };
          language-servers = [ "yaml-language-server" ];
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = "${pkgs.nodePackages.prettier}/bin/prettier";
            args = [ "--parser" "markdown" "--prose-wrap" "always" ];
          };
          language-servers = [ "marksman" ];
        }
        {
          name = "toml";
          auto-format = true;
          formatter = {
            command = "${pkgs.taplo}/bin/taplo";
            args = [ "fmt" "-" ];
          };
          language-servers = [ "taplo" ];
        }
        {
          name = "c";
          auto-format = true;
          formatter = {
            command = "${pkgs.clang-tools}/bin/clang-format";
            args = [ "--style=file" ];
          };
          language-servers = [ "clangd" ];
        }
        {
          name = "cpp";
          auto-format = true;
          formatter = {
            command = "${pkgs.clang-tools}/bin/clang-format";
            args = [ "--style=file" ];
          };
          language-servers = [ "clangd" ];
        }
        {
          name = "c-sharp";
          auto-format = true;
          formatter = {
            command = "${pkgs.csharpier}/bin/dotnet-csharpier";
            args = [ "--write-stdout" ];
          };
          language-servers = [ "omnisharp" ];
        }
        {
          name = "lua";
          auto-format = true;
          formatter = {
            command = "${pkgs.stylua}/bin/stylua";
            args = [ "-" ];
          };
          language-servers = [ "lua-language-server" ];
        }
      ];
    };
    
    themes = {
      tokyonight_transparent = {
        "inherits" = "tokyonight";
        "ui.background" = { };
        "ui.background.separator" = { };
      };
      
      tokyonight_storm_transparent = {
        "inherits" = "tokyonight_storm";
        "ui.background" = { };
        "ui.background.separator" = { };
      };
      
      tokyonight_moon_transparent = {
        "inherits" = "tokyonight_moon";  
        "ui.background" = { };
        "ui.background.separator" = { };
      };
    };
    
    # Extra packages for language servers and formatters
    extraPackages = with pkgs; [
      # Language servers
      nil
      rust-analyzer
      nodePackages.typescript-language-server
      nodePackages.typescript
      python3Packages.python-lsp-server
      nodePackages.yaml-language-server
      marksman
      taplo
      clang-tools
      omnisharp-roslyn
      lua-language-server
      
      # Formatters
      nixpkgs-fmt
      rustfmt
      nodePackages.prettier
      black
      stylua
      csharpier
      
      # Additional tools
      python3Packages.black
      python3Packages.isort
      python3Packages.mypy
      python3Packages.pyflakes
    ];
  };
}