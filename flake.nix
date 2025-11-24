{
  description = "nixos audiobookshelf machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        agenix.nixosModules.default
      ];
      specialArgs = { inherit inputs; };
    };
  };
}