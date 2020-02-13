{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs { }
}:

with pkgs;
let
  nimble = import sources.flake-nimble/flake.nix {  };
in
with nimble;
buildNimble {
  name = "maison";
  src = ./.;
}
