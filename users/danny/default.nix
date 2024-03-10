{ config, pkgs, lib, vars, ... }: 
{
  # imports = [
  #   #../../dots/zsh
  #   # ../../dots/nvim
  #   # ../../dots/git
  # ];

  users.users.danny = {
    #isNormalUser = true;
    description = "Danny";
    #extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
}