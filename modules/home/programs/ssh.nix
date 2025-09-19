{
  config,
  lib,
  ...
}:
let
  # Import our custom lib functions
  moduleLib = import ../../../lib/module { inherit lib; };
  inherit (moduleLib) mkBoolOpt enabled disabled;
  
  # Get the git email from git module config, or use default
  gitEmail = if config.modules.home.programs.git.enable 
    then config.modules.home.programs.git.userEmail 
    else "dark@nightconcept.net";
in
{
  options.modules.home.programs.ssh = {
    enable = mkBoolOpt true "Enable SSH configuration with custom host blocks";
    enableGitSigning = mkBoolOpt true "Enable git SSH signing support by creating allowed_signers file";
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
    home.file.".ssh/id_sdev.pub" = {
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJKTm63zFmYfGauCBlUWq7lvHFq+NVPT5RqIfjLM7MN danny@solivan.dev";
    };
    
    # Create allowed_signers file for git SSH signing
    # This enables git to verify SSH-signed commits
    home.file.".ssh/allowed_signers" = lib.mkIf config.modules.home.programs.ssh.enableGitSigning {
      text = "${gitEmail} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJKTm63zFmYfGauCBlUWq7lvHFq+NVPT5RqIfjLM7MN danny@solivan.dev";
    };
  };
}