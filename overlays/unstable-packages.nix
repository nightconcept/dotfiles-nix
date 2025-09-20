# Overlay to expose unstable packages on stable systems
# Usage: Import this overlay to get access to pkgs.unstable.*
{ inputs }:

final: prev:
let
  # Import unstable nixpkgs
  unstable = import inputs.nixpkgs {
    system = final.system;
    config = {
      allowUnfree = true;
    };
  };
in
{
  # Expose the entire unstable package set
  unstable = unstable;
}