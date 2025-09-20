# Overlay to selectively replace stable packages with unstable versions
# Add package names here that should always use unstable
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
  # Packages that should use unstable versions
  # Add packages here as needed:
  # neovim = unstable.neovim;
  # docker = unstable.docker;
}