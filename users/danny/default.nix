{ config, pkgs, lib, vars, ... }: 
{
  imports = [
    ../../dots/zsh
    # ../../dots/nvim
    # ../../dots/git
  ];

  users.users.danny = {
    shell = pkgs.zsh;
  };
}