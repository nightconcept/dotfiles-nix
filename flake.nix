{
  description = "Nix, NixOS and Nix Darwin System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
    let
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        celes = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules/cli
            ./modules/gui
            ./modules/fonts

            ./users/danny
            ./users/danny/nixos.nix

            ./machines/nixos
            ./machines/nixos/celes
            ];
        };
        cloud = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules/fonts

            ./machines/nixos/cloud
            ];
        };
      };

      darwinConfigurations = {
        waver = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./modules/cli
            ./modules/gui
            ./modules/fonts

            ./users/danny

            ./machines/darwin
            ./machines/darwin/waver
            
            # setup home-manager
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                # include the home-manager module
                #users.danny = import ../home-manager/home.nix;
              };
              users.users.danny.home = "/Users/danny";
            }
          ];
        };
      };
  };
}
