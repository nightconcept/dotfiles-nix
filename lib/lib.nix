{ inputs }:

let
  inherit (inputs) nixpkgs home-manager nix-darwin vscode-server stylix spicetify-nix sops-nix vicinae disko;
in
{
  mkNixos = pkgs: hostname:
    pkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ../modules/nixos
        ../hosts/nixos/${hostname}
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.danny.home.stateVersion = "23.11";
            backupFileExtension = "backup";
            users.danny.imports = [
              ../home
              stylix.homeModules.stylix
              spicetify-nix.homeManagerModules.default
              sops-nix.homeManagerModules.sops
              vicinae.homeManagerModules.default
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
        ../modules/nixos
        ../hosts/nixos/${hostname}
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.danny.home.stateVersion = "23.11";
            backupFileExtension = "backup";
            users.danny.imports = [
              ../home
              stylix.homeModules.stylix
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
        ../modules/darwin
        ../hosts/darwin/${hostname}
        home-manager.darwinModules.home-manager
        {
          users.users.danny.home = "/Users/danny";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.danny.imports = [
              ../home
              stylix.homeModules.stylix
              sops-nix.homeManagerModules.sops
            ];
            extraSpecialArgs = {inherit inputs; inherit hostname;};
          };
        }
      ];
    };
    
  mkHome = hostname:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { 
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [ 
        ../home
        stylix.homeModules.stylix
        spicetify-nix.homeManagerModules.default
        sops-nix.homeManagerModules.sops
      ];
      extraSpecialArgs = { inherit inputs hostname; };
    };
}