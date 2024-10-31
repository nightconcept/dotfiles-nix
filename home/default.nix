{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  programs = {
    home-manager.enable = true;
    firefox.enable = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  imports = [
    ./programs
  ];

  home = {
    username = "danny";
    homeDirectory = "/home/danny";
    stateVersion = "23.11";
  };

  news = {
    display = "silent";
  };
}
