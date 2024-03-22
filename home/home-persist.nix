{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    ./default.nix
    ./persist.nix
  ];
}
