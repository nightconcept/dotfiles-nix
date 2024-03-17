{ config, pkgs, lib, vars, ... }: 
{
  imports = [
  ];

  users.users.danny = {
    shell = pkgs.zsh;
  };
}