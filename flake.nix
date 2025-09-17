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

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    lib = import ./lib/lib.nix { inherit inputs; };
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = {
      tidus = lib.mkNixos inputs.nixpkgs "tidus";
      aerith = lib.mkNixosServer inputs.nixpkgs "aerith";
    };

    darwinConfigurations = {
      waver = lib.mkDarwinLaptop inputs.nixpkgs "waver";
      merlin = lib.mkDarwin inputs.nixpkgs "merlin";
    };

    homeConfigurations = {
      # Generic configurations for standalone home-manager
      desktop = lib.mkHome "x86_64-linux" [ 
        { hostname = "desktop"; }
      ];
      laptop = lib.mkHome "x86_64-linux" [ 
        { hostname = "laptop"; }
      ];
      server = lib.mkHome "x86_64-linux" [ 
        { hostname = "server"; }
      ];
    };
  };
}