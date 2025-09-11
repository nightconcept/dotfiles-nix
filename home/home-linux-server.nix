{
  inputs,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
    extraOptions = ''
      warn-dirty = false
    '';
  };

  home.packages = with pkgs; [
    lazydocker
  ];

  imports = [
    ./programs/common.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/neovim.nix
    ./programs/ssh.nix
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };
}
