{
  inputs,
  lib,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
    extraOptions = ''
      warn-dirty = false
    '';
  };

  home.packages = with pkgs; [
    bat
    btop
    deno
    duf
    erlang_27
    eza
    fastfetch
    git
    gleam
    gh
    lazydocker
    lazygit
    ncdu
    neovim
    nmap
    rsync
    vim
    wget
    zip
    zoxide
  ];

  imports = [
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/ssh.nix
    ./programs/zsh
  ];

  home = {
    username = "danny";
    homeDirectory = lib.mkForce "/home/danny";
    stateVersion = "23.11";
  };
}
