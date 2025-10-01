{
  config,
  lib,
  pkgs,
  ...
}: {
  options.modules.home.programs.gemini-cli = {
    enable = lib.mkEnableOption "gemini-cli AI agent";

    useBinVersion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use gemini-cli-bin (faster updates) or gemini-cli (source build)";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = if config.modules.home.programs.gemini-cli.useBinVersion
                then pkgs.gemini-cli-bin
                else pkgs.gemini-cli;
      description = "The gemini-cli package to use";
    };
  };

  config = lib.mkIf config.modules.home.programs.gemini-cli.enable {
    home.packages = [ config.modules.home.programs.gemini-cli.package ];

    # Verify API key is available at runtime
    home.shellAliases = {
      gemini-check = ''
        if [ -r "$XDG_RUNTIME_DIR/secrets/gemini_api_key" ]; then
          echo "✓ Gemini API key is available"
          echo "Package: ${config.modules.home.programs.gemini-cli.package.name}"
        else
          echo "✗ Gemini API key not found at $XDG_RUNTIME_DIR/secrets/gemini_api_key"
          echo "Make sure SOPS secrets are properly configured"
        fi
      '';
    };

    # Environment variable is already set up in fish.nix via:
    # if test -r "$XDG_RUNTIME_DIR/secrets/gemini_api_key"
    #     set -gx GEMINI_API_KEY (cat "$XDG_RUNTIME_DIR/secrets/gemini_api_key")
  };
}