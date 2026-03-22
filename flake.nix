{
  description = "Chiyuki's Pure Flake Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:

  let
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable {
      inherit system;
    };

  in {
    nixosConfigurations.chiyuki-nanami = nixpkgs.lib.nixosSystem {

      inherit system;

      # Pass unstable into configuration.nix
      specialArgs = { inherit unstable; };

      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.chiyuki = import ./home.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
