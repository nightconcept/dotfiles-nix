{
  inputs,
  lib,
  ...
}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = ["root" "@wheel"];
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
      warn-dirty = false;
      keep-outputs = true;
      keep-derivations = true;
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;
}
