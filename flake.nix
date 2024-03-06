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
          modules = [ ./hosts/celes ];
        };
        cloud = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/cloud ];
        };
      };

      darwinConfigurations = {
        waver = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./hosts/waver ];
        };
      };
  };
}
