{
  config,
  lib,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt enabled disabled;
in
{
  options.modules.home.programs.ssh = {
    enable = mkBoolOpt true "Enable SSH configuration with custom host blocks";
    authorizedKeysAllowed = mkBoolOpt true "Add id_sdev.pub to authorized_keys for SSH access";
  };

  config = lib.mkIf config.modules.home.programs.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      
      matchBlocks = {
        "*" = {
          identityFile = "${config.home.homeDirectory}/.ssh/id_sdev";
        };
        
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
          user = "git";
          identityFile = "${config.home.homeDirectory}/.ssh/id_sdev";
        };
        
        "siren.nclabs.net" = {
          hostname = "siren.nclabs.net";
          user = "danny";
          identityFile = "${config.home.homeDirectory}/.ssh/id_sdev";
        };
      };
    };

    # Deploy the public key (not sensitive, doesn't need encryption)
    home.file.".ssh/id_sdev.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJKTm63zFmYfGauCBlUWq7lvHFq+NVPT5RqIfjLM7MN danny@solivan.dev";

    # Set up authorized_keys with id_sdev for SSH access
    home.file.".ssh/authorized_keys" = lib.mkIf config.modules.home.programs.ssh.authorizedKeysAllowed {
      text = ''
        # Standard development key for remote access
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJKTm63zFmYfGauCBlUWq7lvHFq+NVPT5RqIfjLM7MN danny@solivan.dev
      '';
    };
  };
}