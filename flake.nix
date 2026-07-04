{
  description = "NixOS configurations for home infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgsUnstable,
      agenix,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.linux;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

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

      nixosConfigurations.donato = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/donato/donato.nix
        ];
      };

      nixosConfigurations.oscar = nixpkgsUnstable.lib.nixosSystem {
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
