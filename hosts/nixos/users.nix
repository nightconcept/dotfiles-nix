{ config, pkgs, ... }:
{
  users.users.danny = {
    description = "Danny";
    shell = pkgs.zsh;
    isNormalUser = true;
    hashedPassword = "$6$mG.n4FKuYoY5oNeJ$gYRdmRuFyKnm8qo56VZL8SiQJFJHprFIP96Pe/7TJuYEap9CVsP/pv3K.VSExyi/2uiXOWO00Zz0IRogQRGoC1";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
