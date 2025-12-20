{
  description = "nixos audiobookshelf machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      ...
    }@inputs:
    {
      nixosConfigurations.adriana = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/adriana.nix
          agenix.nixosModules.default
        ];
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations.dasha = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/dasha.nix
        ];
      };

      nixosConfigurations.oscar = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/oscar.nix
          agenix.nixosModules.default
        ];
      };
    };
}
