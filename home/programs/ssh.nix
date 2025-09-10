# WARNING: Keep this file encrypted
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
}

