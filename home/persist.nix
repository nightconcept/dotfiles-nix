{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.persistence."/persist/home" = {
    directories = [
      "Downloads"
      "git"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      ".gnupg"
      ".ssh"
      ".nixops"
      ".zplug" # faster just so plugins don't need to be redownloaded very single time
      ".vscode" # retain plugins, keep save history
      ".local/share/keyrings"
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
