let
  pkgs = import <nixpkgs> {};

  haskellPackages = pkgs.haskell.packages.${ghcVersion}.override { 
    overrides = self: super: {
      # If you need a particular version of a package instead
      # of the default that nixpkgs provides, specify it here.
    };
  };

  haskell = haskellPackages.ghcWithPackages (p: map (name: p.${name}) [
    "aeson"
    "aeson-casing"
    "containers"
    "heroku-persistent"
    "http-api-data"
    "lucid"
    "monad-logger"
    "monad-control"
    "mtl"
    "persistent"
    "persistent-template"
    "persistent-postgresql"
    "servant"
    "servant-lucid"
    "servant-server"
    "text"
    "time"
    "transformers"
    "wai"
    "wai-cors"
    "warp"
    "yaml"
     # etc., the rest of the Hackage packages you use
  ]);


  ghcVersion = "ghc865";

  ghcide =
    let 
      url = "https://github.com/cachix/ghcide-nix/tarball/master";
    in
      (import (builtins.fetchTarball url) {})."ghcide-${ghcVersion}";

in
  pkgs.mkShell {
      buildInputs = [
        haskell
        haskellPackages.ghcid
        ghcide
      ];
    LC_ALL = "en_US.UTF-8";
    # LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    shellHook = ''
      export NIX_GHC="${haskell}/bin/ghc"
      export NIX_GHCPKG="${haskell}/bin/ghc-pkg"
      export NIX_GHC_DOCDIR="${haskell}/share/doc/ghc/html"
      export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
    '';
  }
