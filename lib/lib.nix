{ inputs }:

let
  inherit (inputs) nixpkgs home-manager nix-darwin vscode-server stylix spicetify-nix sops-nix;
in
{
  mkNixos = pkgs: hostname:
    pkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ../systems/nixos
        ../hosts/nixos/${hostname}
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        {
          home-manager = {
            users.danny.home.stateVersion = "23.11";
            backupFileExtension = "backup";
            users.danny.imports = [
              ../home
              stylix.homeModules.stylix
              spicetify-nix.homeManagerModules.default
              sops-nix.homeManagerModules.sops
            ];
            extraSpecialArgs = {inherit inputs; inherit hostname;};
          };
        }
      ];
    };

  mkNixosServer = pkgs: hostname:
    pkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ../systems/nixos
        ../hosts/nixos/${hostname}
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        {
          home-manager = {
            users.danny.home.stateVersion = "23.11";
            users.danny.imports = [
              ../home
              sops-nix.homeManagerModules.sops
            ];
            extraSpecialArgs = {inherit inputs; inherit hostname;};
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
        ../systems/darwin
        ../hosts/darwin/${hostname}
        home-manager.darwinModules.home-manager
        {
          users.users.danny.home = "/Users/danny";
          home-manager = {
            useGlobalPkgs = false;
            backupFileExtension = "backup";
            users.danny.imports = [
              ../home
            ];
            extraSpecialArgs = {inherit inputs; inherit hostname;};
          };
        }
      ];
    };

  mkDarwinLaptop = pkgs: hostname:
    nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs;
      };

      modules = [
        ../systems/darwin
        ../hosts/darwin/${hostname}
        home-manager.darwinModules.home-manager
        {
          users.users.danny.home = "/Users/danny";
          home-manager = {
            useGlobalPkgs = false;
            backupFileExtension = "backup";
            users.danny.imports = [
              ../home
            ];
            extraSpecialArgs = {inherit inputs; inherit hostname;};
          };
        }
      ];
    };
    
  mkHome = hostname:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [ 
        ../home
        stylix.homeModules.stylix
        spicetify-nix.homeManagerModules.default
        sops-nix.homeManagerModules.sops
      ];
      extraSpecialArgs = { inherit inputs hostname; };
    };
}