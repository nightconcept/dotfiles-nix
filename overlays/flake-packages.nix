# Generalized overlay to inject flake packages over npins
# Usage: Add to pinnedPkgs overlays with specific package overrides
{ inputs, overridePackages ? [] }:

final: prev:
let
  flakePkgs = import inputs.nixpkgs {
    system = final.system;
    config = final.config;
  };

  # Create override set from list of package names
  overrides = builtins.listToAttrs (
    map (pkg: { name = pkg; value = flakePkgs.${pkg}; }) overridePackages
  );
in
overrides