{
  description = "Nix, NixOS and Nix Darwin System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    mkNixos = pkgs: hostname:
      pkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos
          ./hosts/nixos/${hostname}
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.danny.home.stateVersion = "23.11";
              useGlobalPkgs = true;
              users.danny.imports = [
                ./home
              ];
            };
          }
        ];
      };
    mkNixosPersist = pkgs: hostname:
      pkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/nixos
          ./hosts/nixos/persist.nix
          ./hosts/nixos/${hostname}
          inputs.home-manager.nixosModules.default
          inputs.impermanence.nixosModules.impermanence
        ];
      };
    mkDarwin = pkgs: hostname:
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./hosts/darwin
          ./hosts/darwin/${hostname}
          home-manager.darwinModules.home-manager
          {
            users.users.danny.home = "/Users/danny";
            home-manager = {
              useGlobalPkgs = false; # makes hm use nixos's pkgs value
              users.danny.imports = [
                ./home/home-darwin.nix
              ];
            };
          }
        ];
      };
    mkHome = system: username: module:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "${system}";};
        modules = [
          ./${module}.nix
        ];
      };
  in {
    nixosConfigurations = {
      celes = mkNixos inputs.nixpkgs "celes";
      cloud = mkNixosPersist inputs.nixpkgs "cloud";
      ifrit = mkNixos inputs.nixpkgs "ifrit";
    };

    darwinConfigurations = {
      waver = mkDarwin inputs.nixpkgs "waver";
      merlin = mkDarwin inputs.nixpkgs "merlin";
    };

    homeConfigurations = {
      danny = mkHome "x86_64-linux" "home";
      danny-darwin = mkHome "aarch64-darwin" "home-darwin";
      danny-server = mkHome "x86_64-linux" "home-server";
    };
  };
}
