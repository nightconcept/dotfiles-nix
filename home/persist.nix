{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home.persistence."/persist/home" = {
    directories = [
      ".config/Code"
      ".config/obsidian"
      ".gnupg"
      ".local/share/keyrings"
      ".nixops"
      ".ssh"
      ".vscode" # retain plugins, keep save historyq
      ".zplug" # faster just so plugins don't need to be redownloaded very single time
      "Downloads"
      "git"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
    ];
    files = [
      ".screenrc"
      ".zsh_history" # for preserving history to help with completions/autosuggestions
    ];
    allowOther = true;
  };

  home.persistence."/persist/dotfiles" = {
    removePrefixDirectory = true; # for GNU Stow styled dotfile folders
    allowOther = true;
    directories = [
      # fuse mounted from /nix/dotfiles/Firefox/.mozilla to /home/$USERNAME/.mozilla
      "Firefox/.mozilla"
    ];
  };
}
