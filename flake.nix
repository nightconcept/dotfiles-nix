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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim-nixvim = {
      url = "github:azuwis/lazyvim-nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lix - Alternative Nix implementation
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dokploy - Self-hosted PaaS platform
    nix-dokploy = {
      url = "github:el-kurto/nix-dokploy";
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
      tidus-persist = lib.mkNixos inputs.nixpkgs "tidus-persist";
      aerith = lib.mkNixosServer inputs.nixpkgs "aerith";
      barrett = lib.mkNixosServer (lib.mkPinnedNixpkgs ./hosts/nixos/barrett) "barrett";
      rinoa = lib.mkNixosServer (lib.mkPinnedNixpkgs ./hosts/nixos/rinoa) "rinoa";
      vincent = lib.mkNixosServer inputs.nixpkgs "vincent";
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

    # Custom installer ISO for tidus-persist
    nixosConfigurations.tidus-persist-installer = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./iso/tidus-persist-installer.nix
      ];
    };
  };
}