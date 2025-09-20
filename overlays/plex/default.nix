# Overlay to use unstable plex on stable systems
{ inputs }:

final: prev:
let
  unstable = import inputs.nixpkgs {
    system = final.system;
    config = {
      allowUnfree = true;
    };
  };
in
{
  plex = unstable.plex;
}