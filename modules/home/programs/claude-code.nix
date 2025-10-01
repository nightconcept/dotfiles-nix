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

  # MCP wrapper scripts for servers that need secrets
  braveSearchMcpScript = pkgs.writeShellScriptBin "brave-search-mcp" ''
    #!/usr/bin/env bash
    BRAVE_API_KEY=$(cat /run/user/1000/secrets/brave_api_key) npx -y @modelcontextprotocol/server-brave-search
  '';

  context7McpScript = pkgs.writeShellScriptBin "context7-mcp" ''
    #!/usr/bin/env bash
    API_KEY=$(cat /run/user/1000/secrets/context7_api_key)
    npx -y @upstash/context7-mcp --api-key "$API_KEY"
  '';

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

      # Brave search (requires API key) - uses wrapper script
      brave-search = if cfg.mcp.brave-search.enable then {
        command = "${braveSearchMcpScript}/bin/brave-search-mcp";
        args = [];
      } else null;

      # Context7 for library docs (requires API key) - uses wrapper script
      context7 = if cfg.mcp.context7.enable then {
        command = "${context7McpScript}/bin/context7-mcp";
        args = [];
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

    glm = {
      enable = mkBoolOpt false "Enable GLM (Z.AI) wrapper script";
      apiKey = mkStrOpt "YOUR_ZAI_API_KEY" "Z.AI API key for GLM models";
      baseUrl = mkStrOpt "https://api.z.ai/api/anthropic" "Z.AI API base URL";
      defaultModel = mkStrOpt "glm-4.6" "Default GLM model to use";
      fastModel = mkStrOpt "glm-4.5-air" "Fast GLM model for auxiliary tasks";
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

      # Wrapper scripts for MCP servers that need secrets
      ".claude/brave-search-mcp.sh" = lib.mkIf (cfg.mcp.enable && cfg.mcp.brave-search.enable) {
        source = "${braveSearchMcpScript}/bin/brave-search-mcp";
        executable = true;
      };

      ".claude/context7-mcp.sh" = lib.mkIf (cfg.mcp.enable && cfg.mcp.context7.enable) {
        source = "${context7McpScript}/bin/context7-mcp";
        executable = true;
      };
    };

    # Install Claude Code package and additional scripts
    home.packages = [ pkgs.claude-code ] ++ (with pkgs; [
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

      # Official Claude Code wrapper (preserves default behavior)
      # Note: claude-code package already provides 'claude' binary
      # This wrapper is commented out to avoid conflicts
      # (writeShellScriptBin "claude" ''
      #   #!/usr/bin/env bash
      #   # Official Anthropic Claude Code
      #   if [ -f ~/.claude/mcp-config.json ]; then
      #     exec ${lib.getExe pkgs.claude-code} --mcp-config ~/.claude/mcp-config.json "$@"
      #   else
      #     exec ${lib.getExe pkgs.claude-code} "$@"
      #   fi
      # '')

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
    ]) ++ lib.optionals cfg.glm.enable [
      # GLM (Z.AI) wrapper script
      (pkgs.writeShellScriptBin "glm" ''
        #!/usr/bin/env bash
        # GLM-powered Claude Code via Z.AI
        export ANTHROPIC_BASE_URL="${cfg.glm.baseUrl}"
        export ANTHROPIC_AUTH_TOKEN="${cfg.glm.apiKey}"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="${cfg.glm.fastModel}"
        export ANTHROPIC_DEFAULT_SONNET_MODEL="${cfg.glm.defaultModel}"
        export ANTHROPIC_DEFAULT_OPUS_MODEL="${cfg.glm.defaultModel}"

        if [ -f ~/.claude/mcp-config.json ]; then
          exec ${lib.getExe pkgs.claude-code} --mcp-config ~/.claude/mcp-config.json "$@"
        else
          exec ${lib.getExe pkgs.claude-code} "$@"
        fi
      '')
    ];

    # Add activation script
    home.activation.claudeCodeSetup = lib.mkIf (cfg.statusline.enable || cfg.mcp.enable || cfg.glm.enable) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ ! -f "$HOME/.claude/.nix_configured" ]; then
          $DRY_RUN_CMD echo "Claude Code configuration available."
          $DRY_RUN_CMD echo "Run 'claude-setup' for setup instructions."
          ${lib.optionalString cfg.glm.enable ''
          $DRY_RUN_CMD echo "GLM wrapper available as 'glm' command."
          ''}
          $DRY_RUN_CMD touch "$HOME/.claude/.nix_configured"
        fi
      ''
    );
  };
}