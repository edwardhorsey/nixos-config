{
  description = "nixos audiobookshelf machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-openwebui.url = "github:NixOS/nixpkgs/4d113fe1f7bb454435a5cabae6cd283e64191bb7"; # 0.7.1
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
        specialArgs = { inherit inputs; };
      };

      nixosConfigurations.dasha = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/dasha/dasha.nix
        ];
        specialArgs = {
          inherit inputs;
          openwebui-pkgs = (import inputs.nixpkgs-openwebui) {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
      };

      nixosConfigurations.oscar = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/oscar/oscar.nix
          agenix.nixosModules.default
        ];
      };
    };
}
