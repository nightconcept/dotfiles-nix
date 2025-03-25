{
  description = "Nix, NixOS and Nix Darwin System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    vscode-server,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    mkNixos = pkgs: hostname:
      pkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/nixos
          ./hosts/nixos/${hostname}
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.danny.home.stateVersion = "23.11";
              backupFileExtension = "backup";
              users.danny.imports = [
                ./home
              ];
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };
    mkNixosServer = pkgs: hostname:
      pkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/nixos
          ./hosts/nixos/${hostname}
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              users.danny.home.stateVersion = "23.11";
              users.danny.imports = [
                ./home/home-nixos-server.nix
              ];
              extraSpecialArgs = {inherit inputs;};
            };
          }
          vscode-server.nixosModules.default
          ({
            config,
            pkgs,
            ...
          }: {
            services.vscode-server.enable = true;
          })
        ];
      };
    mkDarwin = pkgs: hostname:
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./systems/darwin
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
          ./home/${module}.nix
        ];
      };
  in {
    nixosConfigurations = {
      celes = mkNixos inputs.nixpkgs "celes";
      cloud = mkNixos inputs.nixpkgs "cloud";
      ifrit = mkNixos inputs.nixpkgs "ifrit";
      aerith = mkNixosServer inputs.nixpkgs "aerith";
      phoenix = mkNixosServer inputs.nixpkgs "phoenix";
    };

    darwinConfigurations = {
      waver = mkDarwin inputs.nixpkgs "waver";
      merlin = mkDarwin inputs.nixpkgs "merlin";
    };

    homeConfigurations = {
      desktop = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "x86_64-linux";};
        modules = [
          ./home/home-desktop.nix
        ];
      };
      server = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "x86_64-linux";};
        modules = [
          ./home/home-server.nix
        ];
      };
      wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "x86_64-linux";};
        modules = [
          ./home/home-wsl.nix
        ];
      };
    };
  };
}
