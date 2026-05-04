{
  description = "nixos audiobookshelf machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
          ./machines/adriana/adriana.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.dasha = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/dasha/dasha.nix
        ];
      };

      nixosConfigurations.oscar = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/oscar/oscar.nix
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.t14 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/t14/t14.nix
        ];
      };
    };
}
