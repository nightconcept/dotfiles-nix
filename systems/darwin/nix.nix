{
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = ["danny"];
    gc = {
      automatic = true;
      user = "danny";
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

  services.nix-daemon.enable = true;

  system.stateVersion = 4;
}
