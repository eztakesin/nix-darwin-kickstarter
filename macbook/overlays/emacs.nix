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
      epkgs.benchmark-init
      epkgs.dash
      epkgs.diff-hl
      epkgs.elysium
      epkgs.f
      epkgs.goto-line-preview
      epkgs.gptel
      epkgs.holo-layer
      epkgs.inf-ruby
      epkgs.isearch-mb
      epkgs.json-reformat
      epkgs.json-snatcher
      epkgs.lsp-bridge
      epkgs.move-text
      epkgs.olivetti
      epkgs.cider
      epkgs.clojure-mode
      epkgs.clojure-ts-mode
      epkgs.coffee-mode
      epkgs.dart-mode
      epkgs.elixir-mode
      epkgs.fsharp-mode
      epkgs.go-mode
      epkgs.haskell-mode
      epkgs.json-mode
      epkgs.kotlin-mode
      epkgs.llvm-mode
      epkgs.lua-mode
      epkgs.markdown-mode
      epkgs.markdown-ts-mode
      epkgs.nim-mode
      epkgs.nix-mode
      epkgs.parseclj
      epkgs.parseedn
      epkgs.php-mode
      epkgs.queue
      epkgs.rjsx-mode
      epkgs.rust-mode
      epkgs.sly
      epkgs.solidity-mode
      epkgs.swift-mode
      epkgs.tuareg
      epkgs.typescript-mode
      epkgs.web-mode
      epkgs.vala-mode
      epkgs.zig-mode
      epkgs.popper
      epkgs.posframe
      epkgs.projectile
      epkgs.projectile-rails
      epkgs.rcirc-color
      epkgs.reformatter
      epkgs.rime
      epkgs.ruby-electric
      epkgs.ruby-tools
      epkgs.sesman
      epkgs.slime
      epkgs.smex
      epkgs.symbol-overlay
      epkgs.transient
      epkgs.typescript-mode
      epkgs.valign
      epkgs.visual-regexp
      epkgs.vundo
      epkgs.websocket
      epkgs.ws-butler
      epkgs.xterm-color
      epkgs.yasnippet
      epkgs.yasnippet-snippets
    ];
  };
}