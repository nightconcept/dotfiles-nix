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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
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
      mkNixosPersist  = pkgs: hostname:
        pkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules
            ./users/danny
            ./users/danny/nixos.nix
            ./machines/nixos
            ./machines/nixos/persist.nix
            ./machines/nixos/${hostname}
            inputs.disko.nixosModules.default
            (import ./machines/nixos/disko.nix { device = "/dev/nvme0n1"; }) # TODO change me
            inputs.home-manager.nixosModules.default
            inputs.impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager {
              home-manager = {
                users.danny.home.stateVersion = "23.11";
                useGlobalPkgs = true;
                users.danny.imports = [ 
                  ./users/danny/home-persist.nix                 
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
                useGlobalPkgs = false; # makes hm use nixos's pkgs value
                users.danny.imports = [ 
                  ./users/danny/home-darwin.nix                 
                ];
              };
            }
          ];
        };
      mkHome = system: username: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "${system}"; };
          modules = [ 
            ./users/${username}/${module}.nix 
          ];
        };
    in {
      nixosConfigurations = {
        celes = mkNixos inputs.nixpkgs "celes";
        cloud = mkNixos inputs.nixpkgs "cloud";
        cloud-next = mkNixosPersist inputs.nixpkgs "cloud-next";
        ifrit = mkNixos inputs.nixpkgs "ifrit";
      };

      darwinConfigurations = {
        waver = mkDarwin inputs.nixpkgs "waver";
        merlin = mkDarwin inputs.nixpkgs "merlin";
      };
      
      homeConfigurations = {
        danny = mkHome "x86_64-linux" "danny" "home";
        danny-darwin = mkHome "aarch64-darwin" "danny" "home-darwin";
        danny-server = mkHome "x86_64-linux" "danny" "home-server";
      };
    };
}
