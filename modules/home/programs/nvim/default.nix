{ config, lib, pkgs, inputs, osConfig ? {}, ... }:

with lib;
let
  cfg = config.modules.home.programs.nvim;

  # Check if we have the astronvim input (it's a module-based flake)
  astronvimAvailable = inputs ? astronvim && inputs.astronvim ? nixosModules;

  # Distribution packages abstraction
  distroPackages = {
    basic = [ pkgs.neovim ];
    nvchad = [ inputs.nvchad.packages.${pkgs.system}.nvchad ];
    lazyvim = [ inputs.lazyvim-nixvim.packages.${pkgs.system}.default ];
    astronvim = [ pkgs.neovim ];  # AstroNvim is configured via module, not package
  };
in {
  options.modules.home.programs.nvim = {
    enable = mkEnableOption "neovim configuration";

    distro = mkOption {
      type = types.enum [ "basic" "nvchad" "lazyvim" "astronvim" ];
      default = "basic";
      description = "The neovim distribution to use";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install alongside nvim";
      example = literalExpression "[ pkgs.ripgrep pkgs.fd ]";
    };

    aliases = {
      vim = mkOption {
        type = types.bool;
        default = true;
        description = "Create 'vim' alias for nvim";
      };

      vi = mkOption {
        type = types.bool;
        default = true;
        description = "Create 'vi' alias for nvim";
      };
    };

    # AstroNvim-specific options (only when using astronvim distro)
    astronvim = {
      username = mkOption {
        type = types.str;
        default = config.home.username or "danny";
        description = "Username for AstroNvim configuration";
      };

      nerdfont = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use nerd fonts in AstroNvim";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Base configuration for all distros
    {
      home.packages =
        (distroPackages.${cfg.distro} or [])
        ++ cfg.extraPackages;

      # Create shell aliases if requested
    programs.fish.shellAliases = mkIf config.programs.fish.enable {
      vim = mkIf cfg.aliases.vim "nvim";
      vi = mkIf cfg.aliases.vi "nvim";
    };

    programs.bash.shellAliases = mkIf config.programs.bash.enable {
      vim = mkIf cfg.aliases.vim "nvim";
      vi = mkIf cfg.aliases.vi "nvim";
    };

    programs.zsh.shellAliases = mkIf config.programs.zsh.enable {
      vim = mkIf cfg.aliases.vim "nvim";
      vi = mkIf cfg.aliases.vi "nvim";
    };

      # Set default editor
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    }

    # AstroNvim-specific configuration
    (mkIf (cfg.distro == "astronvim" && astronvimAvailable) {
      # Import AstroNvim module when available and selected
      imports = [ inputs.astronvim.nixosModules.astroNvim ];

      programs.astroNvim = {
        enable = true;
        username = cfg.astronvim.username;
        nerdfont = cfg.astronvim.nerdfont;
      };
    })
  ]);
}