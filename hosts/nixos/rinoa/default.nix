{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = {
    nixos = {
      core = {
        enable = true;
        hostname = "rinoa";
        username = "danny";
        timezone = "America/Los_Angeles";
      };

      networking = {
        enable = true;
        useDHCP = true;
      };

      ssh = {
        enable = true;
        allowPasswordAuth = false;
      };

      docker = {
        enable = true;
      };
    };
  };

  system.stateVersion = "24.05";
}