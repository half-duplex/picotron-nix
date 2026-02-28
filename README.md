# picotron-nix

1. Download the [Picotron](https://www.lexaloffle.com/picotron.php) zip that
   matches the version in default.nix, e.g. picotron\_0.2.2b\_amd64.zip
2. Add it to the nix store with `nix store add-path picotron_*_amd64.zip`
3. Run Picotron:
   If you have `{allowUnfree=true;}` in `~/.config/nixpkgs/config.nix`,
   `NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:half-duplex/picotron-nix`

You will need to do step 2 each time Picotron and this package are updated.
`--impure` is unfortunately [required](https://github.com/NixOS/nix/issues/9875)
for `NIXPKGS_ALLOW_UNFREE=1`, which in turn is
[needed](https://nixos.wiki/wiki/Unfree_Software) because of Picotron's
non-open-source license.

For similar reasons, adding this to your system flake requires an overlay,
which is provided as a module.
```nix
{
  inputs.picotron.url = "github:half-duplex/picotron-nix";
  inputs.picotron.inputs.nixpkgs.follows = "nixpkgs";
  # ...

  outputs = { self, nixpkgs, picotron }: {
    nixosConfigurations.yourpc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        picotron.nixosModules.default
        # ...
      ];
    };
  };
}
```
