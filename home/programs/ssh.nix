# SSH configuration
{config, ...}: {
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
}

