{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  programs.home-manager.enable = true;

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  news = {
    display = "silent";
  };
}
