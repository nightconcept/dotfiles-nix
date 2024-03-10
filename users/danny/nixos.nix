{ config, pkgs, ... }:
{
  users.users.danny = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
