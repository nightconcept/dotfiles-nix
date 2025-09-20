{
  description = "Nix, NixOS and Nix Darwin System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Lix - A modern, delicious implementation of Nix  
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Vicinae - High-performance launcher for Linux
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim-nixvim = {
      url = "github:azuwis/lazyvim-nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    home-manager-stable,
    ...
  } @ inputs: let
    lib = import ./lib/lib.nix { inherit inputs; };
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = {
      tidus = lib.mkNixos inputs.nixpkgs "tidus";
      aerith = lib.mkNixosServer inputs.nixpkgs-stable "aerith";
      barrett = lib.mkNixosServer inputs.nixpkgs-stable "barrett";
      rinoa = lib.mkNixosServer inputs.nixpkgs-stable "rinoa";
      vincent = lib.mkNixosServer inputs.nixpkgs-stable "vincent";
    };

    darwinConfigurations = {
      waver = lib.mkDarwin inputs.nixpkgs "waver";
      merlin = lib.mkDarwin inputs.nixpkgs "merlin";
    };

    homeConfigurations = {
      # Generic configurations for standalone home-manager
      desktop = lib.mkHome "desktop";
      laptop = lib.mkHome "laptop";
      server = lib.mkHome "server";
    };
  };
}