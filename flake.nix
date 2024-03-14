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
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations = {
        celes = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules/fonts

            ./users/danny
            ./users/danny/nixos.nix

            ./machines/nixos
            ./machines/nixos/celes

            home-manager.nixosModules.home-manager {
              home-manager = {
                users.danny.home.stateVersion = "23.11";
                useGlobalPkgs = false; # makes hm use nixos's pkgs value
                users.danny.imports = [ 
                  ./users/danny/home.nix                 
                ];
              };
            }
          ];
        };
        cloud = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules/fonts

            ./users/danny
            ./users/danny/nixos.nix

            ./machines/nixos
            ./machines/nixos/cloud

            home-manager.nixosModules.home-manager {
              home-manager = {
                users.danny.home.stateVersion = "23.11";
                useGlobalPkgs = false; # makes hm use nixos's pkgs value
                users.danny.imports = [ 
                  ./users/danny/home.nix                 
                ];
              };
            }
          ];
        };
      ifrit = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./users/danny

            ./machines/nixos/ifrit
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
            ./modules/fonts/darwin-fonts.nix

            ./users/danny

            ./machines/darwin
            ./machines/darwin/waver

            home-manager.darwinModules.home-manager {
              users.users.danny.home = "/Users/danny";
              home-manager = {
                users.danny.home.stateVersion = "23.11";
                useGlobalPkgs = false; # makes hm use nixos's pkgs value
                users.danny.imports = [ 
                  ./users/danny/darwin-home.nix                 
                ];
              };
            }
          ];
        };

        merlin = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          
          specialArgs = {
            inherit inputs;
          };
          
          modules = [
            ./modules/fonts/darwin-fonts.nix

            ./users/danny

            ./machines/darwin

            home-manager.darwinModules.home-manager {
              users.users.danny.home = "/Users/danny";
              home-manager = {
                users.danny.home.stateVersion = "23.11";
                useGlobalPkgs = false; # makes hm use nixos's pkgs value
                users.danny.imports = [ 
                  ./users/danny/darwin-home.nix                 
                ];
              };
            }
          ];
        };
      };
      
      homeConfigurations = {
        danny = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ 
            ./users/danny/home.nix 
          ];
        };
      };
    };
}
