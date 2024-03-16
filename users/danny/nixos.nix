{ config, pkgs, ... }:
{
  users.users.danny = {
    isNormalUser = true;
    initialPassword = "1";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
