{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt mkOpt enabled;

  # Helper for string options
  mkStrOpt = default: desc: mkOpt lib.types.str default desc;

  cfg = config.modules.home.programs.claude-code;

  # Claude Code statusline configuration
  claudeStatuslineConfig = pkgs.writeText "claude-statusline.json" (builtins.toJSON {
    input = {
      # Git-aware statusline with context
      script = ''
        #!/bin/bash

        # Get git info
        if git rev-parse --git-dir > /dev/null 2>&1; then
          branch=$(git branch --show-current 2>/dev/null || echo "detached")
          changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
          if [ "$changes" -gt 0 ]; then
            git_status="$branch*"
          else
            git_status="$branch"
          fi
        else
          git_status="no-git"
        fi

        # Get current directory (shortened)
        dir=$(dirs +0)
        dir=''${dir/#$HOME/\~}

        # Get system info
        hostname=$(hostname -s)

        # Get language/project context
        if [ -f "package.json" ]; then
          context="node"
        elif [ -f "Cargo.toml" ]; then
          context="rust"
        elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
          context="python"
        elif [ -f "flake.nix" ]; then
          context="nix"
        elif [ -f "go.mod" ]; then
          context="go"
        else
          context=""
        fi

        # Build output
        output="[$hostname:$dir]"
        if [ -n "$git_status" ] && [ "$git_status" != "no-git" ]; then
          output="$output [$git_status]"
        fi
        if [ -n "$context" ]; then
          output="$output [$context]"
        fi

        echo "$output"
      '';
      # Refresh every 2 seconds
      refreshIntervalMs = 2000;
    };
  });

  # MCP server configuration
  mcpConfig = pkgs.writeText "mcp-config.json" (builtins.toJSON {
    mcpServers = lib.filterAttrs (n: v: v != null) {
      # Sequential thinking server for problem-solving
      sequential-thinking = if cfg.mcp.sequential-thinking.enable then {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-sequential-thinking" ];
      } else null;

      # Filesystem server with configurable paths
      filesystem = if cfg.mcp.filesystem.enable then {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-filesystem" ] ++ cfg.mcp.filesystem.paths;
      } else null;

      # Puppeteer for web automation
      puppeteer = if cfg.mcp.puppeteer.enable then {
        command = "npx";
        args = [ "-y" "@modelcontextprotocol/server-puppeteer" ];
      } else null;

      # Enhanced fetch server
      fetch = if cfg.mcp.fetch.enable then {
        command = "npx";
        args = [ "-y" "@kazuph/mcp-fetch" ];
      } else null;

      # Brave search (requires API key)
      brave-search = if cfg.mcp.brave-search.enable then {
        command = "bash";
        args = [
          "-c"
          "BRAVE_API_KEY=$(cat ${config.sops.secrets.brave_api_key.path}) npx -y @modelcontextprotocol/server-brave-search"
        ];
      } else null;

      # Context7 for library docs (requires API key)
      context7 = if cfg.mcp.context7.enable then {
        command = "bash";
        args = [
          "-c"
          "npx -y @upstash/context7-mcp --api-key $(cat ${config.sops.secrets.context7_api_key.path})"
        ];
      } else null;
    };
  });
in
{
  options.modules.home.programs.claude-code = {
    enable = mkBoolOpt true "Enable Claude Code configuration";

    statusline = {
      enable = mkBoolOpt true "Enable custom Claude Code statusline";
      config = mkOpt lib.types.attrs {} "Custom statusline configuration";
    };

    mcp = {
      enable = mkBoolOpt true "Enable MCP server configuration";

      sequential-thinking = {
        enable = mkBoolOpt true "Enable sequential thinking MCP server";
      };

      filesystem = {
        enable = mkBoolOpt true "Enable filesystem MCP server";
        paths = mkOpt (lib.types.listOf lib.types.str) [
          "$HOME/Documents"
          "$HOME/Desktop"
          "$HOME/Downloads"
        ] "Paths accessible to the filesystem MCP server";
      };

      puppeteer = {
        enable = mkBoolOpt true "Enable Puppeteer MCP server for web automation";
      };

      fetch = {
        enable = mkBoolOpt true "Enable enhanced fetch MCP server";
      };

      brave-search = {
        enable = mkBoolOpt false "Enable Brave Search MCP server (uses SOPS secret)";
      };

      context7 = {
        enable = mkBoolOpt false "Enable Context7 MCP server for library docs (uses SOPS secret)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the Claude Code configuration directory and files
    home.file = {
      ".claude/statusline.json" = lib.mkIf cfg.statusline.enable {
        source = claudeStatuslineConfig;
      };

      ".claude/mcp-config.json" = lib.mkIf cfg.mcp.enable {
        source = mcpConfig;
      };
    };

    # Create a setup script to configure Claude Code
    home.packages = with pkgs; [
      (writeShellScriptBin "claude-setup" ''
        #!/usr/bin/env bash
        set -e

        echo "=== Claude Code Configuration Setup ==="
        echo ""

        # Check if Claude Code is running
        if pgrep -f "claude" > /dev/null 2>&1; then
          echo "⚠️  Warning: Claude Code appears to be running."
          echo "   Some changes may require restarting Claude Code."
          echo ""
        fi

        # Ensure directory exists
        mkdir -p ~/.claude

        # Statusline setup
        if [ -f ~/.claude/statusline.json ]; then
          echo "✓ Statusline configuration found at ~/.claude/statusline.json"
          echo ""
          echo "To apply the statusline, run in Claude Code:"
          echo "  /statusline ~/.claude/statusline.json"
        else
          echo "✗ No statusline configuration found"
        fi

        echo ""

        # MCP setup
        if [ -f ~/.claude/mcp-config.json ]; then
          echo "✓ MCP configuration found at ~/.claude/mcp-config.json"
          echo ""
          echo "To apply MCP servers, start Claude Code with:"
          echo "  claude --mcp-config ~/.claude/mcp-config.json"
          echo ""
          echo "Or add them individually with commands like:"
          echo "  claude mcp add-from-claude-desktop"
          echo ""
          echo "Current MCP servers configured in Nix:"
          cat ~/.claude/mcp-config.json | jq -r '.mcpServers | keys[]' 2>/dev/null || echo "  (unable to parse)"
        else
          echo "✗ No MCP configuration found"
        fi

        echo ""
        echo "To see currently active MCP servers, run:"
        echo "  claude mcp list"
      '')

      # Helper to start Claude with MCP config
      (writeShellScriptBin "claude-mcp" ''
        #!/usr/bin/env bash
        if [ -f ~/.claude/mcp-config.json ]; then
          exec claude --mcp-config ~/.claude/mcp-config.json "$@"
        else
          echo "MCP config not found. Run 'claude-setup' first."
          exit 1
        fi
      '')
    ];

    # Add activation script
    home.activation.claudeCodeSetup = lib.mkIf (cfg.statusline.enable || cfg.mcp.enable) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -f "$HOME/.claude/.nix_configured" ]; then
          $DRY_RUN_CMD echo "Claude Code configuration available."
          $DRY_RUN_CMD echo "Run 'claude-setup' for setup instructions."
          $DRY_RUN_CMD touch "$HOME/.claude/.nix_configured"
        fi
      ''
    );
  };
}