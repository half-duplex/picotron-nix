{
  description = "Picotron!";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages = forAllSystems (system: {
      default = self.packages.picotron;
      picotron = nixpkgsFor.${system}.callPackage ./package.nix {};
    });

    nixosModules = {
      default = self.nixosModules.picotron;
      picotron = {...}: {
        config.nixpkgs.overlays = [self.overlays.default];
      };
    };
    overlays.default = final: _: {
      picotron = final.callPackage ./package.nix {};
    };

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);
  };
}
