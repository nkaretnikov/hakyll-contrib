{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

with nixpkgs.pkgs;
let
  selectedHaskellPackages = if compiler == "default"
                            then haskellPackages
                            else pkgs.haskell.packages.${compiler};

  modifiedHaskellPackages = selectedHaskellPackages.override {
    overrides = self: super: {
      pandoc = self.callPackage ../pandoc {};
    };
  };

  f = { mkDerivation, base, cabal-install, directory, filepath, hakyll
      , pandoc, stdenv
      }:
      mkDerivation {
        pname = "hakyll-contrib";
        version = "0.1.0.1";
        sha256 = "./.";
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [ base hakyll pandoc ];
        executableHaskellDepends = [ base directory filepath hakyll ];
        buildTools = [ cabal-install ];
        homepage = "http://jaspervdj.be/hakyll";
        description = "Extra modules for the hakyll website compiler";
        license = stdenv.lib.licenses.bsd3;
      };

  drv = modifiedHaskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
