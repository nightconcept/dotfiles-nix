# Update NixPkgs

## Update Package

1. Find package.nix file for example: pkgs/by-name/he/hello/package.nix
2. Get latest hash using:
```sh
nix-prefetch-github-latest-release <owner> <repo>
```
3. Update package.nix file with new version and hash.
4. Submit PR to NixPkgs.

## Add new package:

Follow this [guide](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#quick-start-to-adding-a-package).
