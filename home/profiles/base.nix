# Base configuration shared across all machines
{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home
  ];

  modules.home = {
    programs = {
      claude-code = {
        enable = true;
        # Enable MCP servers that don't require API keys by default
        mcp = {
          sequential-thinking.enable = true;
          filesystem.enable = true;
          puppeteer.enable = true;
          fetch.enable = true;
          # API keys are managed via SOPS secrets
          brave-search.enable = true;
          context7.enable = true;
        };
      };
      common.enable = true;
      direnv.enable = true;
      gemini-cli.enable = true;  # Uses bin version by default
      git.enable = true;
      nvim = {
        enable = true;
        distro = "nvchad";
      };
      ssh.enable = true;
    };
    secrets = {
      sops.enable = true;
    };
  };

  home = {
    username = "danny";
    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;

  news.display = "silent";
}