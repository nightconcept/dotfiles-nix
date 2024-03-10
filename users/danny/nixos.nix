{ config, pkgs, lib, vars, ... }: 
{
  users.users.danny = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}