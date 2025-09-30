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
          # These require API keys - enable them after adding secrets
          brave-search.enable = false;  # Set to true and configure apiKey
          context7.enable = false;       # Set to true and configure apiKey
        };
      };
      common.enable = true;
      direnv.enable = true;
      git.enable = true;
      helix.enable = true;
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