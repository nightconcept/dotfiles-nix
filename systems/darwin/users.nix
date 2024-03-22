{ config, pkgs, lib, vars, ... }: 
{
  users.users.danny = {
    description = "Danny";
    shell = pkgs.zsh;
  };
}