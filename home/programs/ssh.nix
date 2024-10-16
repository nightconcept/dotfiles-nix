# WARNING: Keep this file encrypted
{config, ...}: {
  programs.ssh = {
    enable = true;
    extraConfig = ''
    IdentityFile ${config.home.homeDirectory}/.ssh/id_sdev

    Host github.com
        Hostname ssh.github.com
        Port 443
        User git
        IdentityFile=${config.home.homeDirectory}/.ssh/id_sdev

    Host siren.nclabs.net
      HostName siren.nclabs.net
      User danny
      IdentityFile=${config.home.homeDirectory}/.ssh/id_sdev
    '';
  };
}

