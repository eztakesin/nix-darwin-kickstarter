{
  pkgs,
  lib,
  inputs,
  ...
}: {
  nix = {
    # Determinate uses its own daemon to manage the Nix installation that
    # conflicts with nix-darwin's native Nix management.
    #
    # TODO: set this to false if you're using Determinate Nix.
    # NOTE: Turning off this option will invalidate all of the following nix configurations,
    # and you will need to manually modify /etc/nix/nix.custom.conf to add the corresponding parameters.
    enable = true;

    # Deliberately tracking the newest Nix release; fall back to the
    # default `pkgs.nix` (stable) if a fresh release misbehaves.
    package = pkgs.nixVersions.latest;

    # Flake-only workflow — no nix-channel machinery.
    channel.enable = false;

    settings = {
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # substituers that will be considered before the official ones(https://cache.nixos.org)
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      builders-use-substitutes = true;

      # Disable auto-optimise-store because of this issue:
      #   https://github.com/NixOS/nix/issues/7273
      # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
      auto-optimise-store = false;

      # Never consult the online global flake registry.
      flake-registry = "";

      # Fail fast on flaky links (Starlink) instead of hanging.
      connect-timeout = 10;
      download-attempts = 3;
      stalled-download-timeout = 10;

      # Pure-eval contexts resolve <nixpkgs> to the pinned input too
      # (companion to nixPath below).
      nix-path = "nixpkgs=${inputs.nixpkgs}";
    };

    # Register EVERY flake input in the system registry (self excluded):
    # `nix shell nixpkgs#foo` / `nixpkgs-stable#foo` / `home-manager#…` all
    # resolve to the exact pinned revisions (same binary cache as the
    # system). Side effect that replaces a separate keep-flake-inputs
    # module: registry.json holds the inputs' store paths, so they are part
    # of the system closure and survive `nix gc` — no re-downloading every
    # input after each collection.
    registry =
      lib.mapAttrs (_: flake: {inherit flake;})
      (lib.filterAttrs (name: _: name != "self") inputs);
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    # Do garbage collection weekly to keep disk usage low
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
