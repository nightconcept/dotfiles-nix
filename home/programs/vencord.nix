{ config, pkgs, ... }: {
  programs.vencord = {
    enable = true;
    discord = {
      package = pkgs.discord;
    };
  };
}