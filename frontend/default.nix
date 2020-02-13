{ sources ? import ../nix/sources.nix
, pkgs ? import sources.nixpkgs { }
, nodejs ? pkgs."nodejs-12_x" }:

let
  nodeEnv = import ./node-env.nix {
    inherit (pkgs) stdenv python2 utillinux runCommand writeTextFile;
    inherit nodejs;
    libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
  };

  nodePackages = import ./node-packages.nix {
    inherit (pkgs) fetchurl fetchgit;
    inherit nodeEnv;
  };

  result = nodePackages.package;

in pkgs.stdenv.mkDerivation {
  name = "maison-frontend-proper";
  buildInputs = [ result ];
  unpackPhase = "true";

  installPhase = ''
    export NODE_PATH=${result}/lib/node_modules/maison-frontend/node_modules
    export PATH="$NODE_PATH/.bin:$PATH"
    set -x
    mkdir -p $out/public
    browserify ${result}/lib/node_modules/maison-frontend/index.js -o $out/public/bundle.js
    set +x
  '';
}
