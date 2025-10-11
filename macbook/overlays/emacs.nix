# overlays/emacs.nix
final: prev: {
  emacs-overlays = prev.emacsWithPackagesFromUsePackage {
    config = let
      inherit (final) lib;

      readRecursively = dir:
        builtins.concatStringsSep "\n"
        (lib.mapAttrsToList (name: value:
          if value == "regular"
          then builtins.readFile (dir + "/${name}")
          else if value == "directory"
          then readRecursively (dir + "/${name}")
          else []
        ) (builtins.readDir dir));
    in
      readRecursively ./emacs;

    package = prev.emacs-unstable;

    extraEmacsPackages = epkgs: [
      epkgs.use-package
      epkgs.magit
    ];
  };
}