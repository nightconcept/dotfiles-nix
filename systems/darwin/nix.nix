{
  pkgs,
  lib,
  ...
}: {
  nix = {
    optimise.automatic = true;
    settings = {
      allowed-users = ["danny"];
      trusted-users = ["root" "danny" "@wheel"];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    extraOptions =
      ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      ''
      + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 4;
}
