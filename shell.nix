let
  sources = import ./nix/sources.nix;
  niv = (import sources.niv { }).niv;
  pkgs = import sources.nixpkgs { };
in
with pkgs;
mkShell {
  buildInputs = [
    niv
    nim
    nodejs
    nodePackages.node2nix
  ];
}
