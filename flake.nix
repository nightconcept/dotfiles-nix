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
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      mkNixos = pkgs: hostname:
        pkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules
            ./users/danny
            ./users/danny/nixos.nix
            ./machines/nixos
            ./machines/nixos/${hostname}

            home-manager.nixosModules.home-manager {
              home-manager = {
                users.danny.home.stateVersion = "23.11";
                useGlobalPkgs = true;
                users.danny.imports = [ 
                  ./users/danny/home.nix                 
                ];
              };
            }
          ];
        };
      mkDarwin = pkgs: hostname:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs;
          };
          
          modules = [
            ./modules/darwin.nix
            ./users/danny
            ./machines/darwin
            ./machines/darwin/${hostname}

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
      mkHome = pkgs: username: module:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs
          modules = [ 
            ./users/${username}/${module}.nix 
          ];
        };
    in {
      nixosConfigurations = {
        celes = mkNixos inputs.nixpkgs "celes";
        cloud = mkNixos inputs.nixpkgs "cloud";
        ifrit = mkNixos inputs.nixpkgs "ifrit";
      };

      darwinConfigurations = {
        waver = mkDarwin inputs.nixpkgs "waver";
        merlin = mkDarwin inputs.nixpkgs "merlin";
      };
      
      homeConfigurations = {
        danny = mkHome inputs.nixpkgs "danny" "home";
        danny-server = mkHome inputs.nixpkgs "danny" "home-server";
      };
    };
}
