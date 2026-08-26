{
  description = "Nix for macOS configuration";

  nixConfig = {
    substituters = ["https://cache.nixos.org"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # (removed 2026-07-25) nixpkgs-stable: the cache-wave fallback input.
    # Re-add together with its pin overlay if Hydra's aarch64-darwin
    # cache ever lags a stdenv rebuild again (see overlays list note).

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Official Rust dist binaries repackaged as coherent toolchains
    # (nightly channel, per-component extensions). See home/rust.nix.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin-emacs = {
      url = "github:nix-giant/nix-darwin-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin-emacs-packages = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    twist.url = "github:emacs-twist/twist.nix";

    emacs-config = {
      url = "github:klchen0112/emacs-config-package";
      inputs.twist.follows = "twist";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    darwin-emacs,
    darwin-emacs-packages,
    emacs-config,
    ...
  }: let
    # System info
    system = "aarch64-darwin";
    hostname = "macbook";
    username = "macbook";
    useremail = "qwquq@proton.me";

    # Lib
    lib = nixpkgs.lib;

    # Overlays
    overlays = [
      darwin-emacs.overlays.emacs
      darwin-emacs-packages.overlays.package
      (import ./overlays/emacs.nix)
      # Provides pkgs.rust-bin.* — consumed by home/rust.nix.
      inputs.rust-overlay.overlays.default
      # (removed 2026-07-25, the great teardown) deno doCheck=false and
      # python313Packages.jeepney install-check skip: cache-miss-era
      # relics; both packages ride Hydra's cache again.
      #
      # pipx + pylsp-mypy doCheck=false SURVIVED the teardown, verified
      # 2026-07-25: their upstream test suites are genuinely broken
      # (pipx: 18 collection errors; pylsp-mypy: asserts on mypy's error
      # text), so HYDRA cannot build them either — there is no cached
      # plain drv to lose. These two stay local-built until upstream
      # fixes their tests. Must override at the interpreter level:
      # `pkgs.pipx` is `python3.pkgs.toPythonApplication python3.pkgs
      # .pipx`, so the checkPhase runs inside `python3.pkgs.pipx`.
      (final: prev: let
        packageOverrides = pself: psuper: {
          pipx = psuper.pipx.overridePythonAttrs (_: {
            doCheck = false;
          });
          pylsp-mypy = psuper.pylsp-mypy.overridePythonAttrs (_: {
            doCheck = false;
          });
          # python-lsp-ruff 2.3.1: two tests assert ruff reports E402,
          # but current ruff's rule behaviour changed and it no longer
          # appears (2 failed / 12 passed). Same class as the two above:
          # Hydra fails identically, so there is no cached drv to lose.
          python-lsp-ruff = psuper.python-lsp-ruff.overridePythonAttrs (_: {
            doCheck = false;
          });
          # TEMPORARY mirror of nixpkgs#554405 (merged 2026-08-20, hours
          # after this pin): test_verify's expected error regex no longer
          # matches newer curl/http3 error text. DROP once the nixpkgs pin
          # advances past the merge (the in-tree expression then carries
          # these same skips and this override only forces a rebuild).
          curl-cffi = psuper.curl-cffi.overridePythonAttrs (old: {
            disabledTestPaths =
              (old.disabledTestPaths or [])
              ++ [
                "tests/unittest/test_async_session.py::test_verify"
                "tests/unittest/test_curl.py::test_verify"
                "tests/unittest/test_requests.py::test_verify"
                "tests/unittest/test_requests.py::test_delete_cookies"
              ];
          });
        };
      in {
        python3 = prev.python3.override (old: {inherit packageOverrides;});
        # python314 is a separate attr — home/core.nix builds myPython
        # from it, so it needs the same overrides.
        python314 = prev.python314.override (old: {inherit packageOverrides;});
      })
      #
      # (removed 2026-07-25) THE LIBFFI SCAFFOLD — libffiAppleFixed
      # (-no_fixup_chains relink) + python314FixedFfi (recursive self,
      # pythonAttr, cffi/pyobjc-core libffi rewires, six beta-flaky
      # per-test disables) + the yt-dlp/pipx/yubikey-manager migrations.
      # macOS 27's dyld rejected the trampoline dylib cctools ld emitted;
      # fixed upstream by nixpkgs#541990 (credits: this flake's author),
      # which reached nixpkgs-unstable at 6d120041. Plain python3 verified
      # on-device: `import ctypes` clean from the binary cache.
      # History: git log around 2ac9390..bab2d63, and issue #541367.
      # highlight: nixpkgs carries shellscript-crash-fix.patch but upstream
      # already merged it into 4.20, so the patch fails with "Reversed (or
      # previously applied) patch detected". Drop it.
      (final: prev: {
        highlight = prev.highlight.overrideAttrs (old: {
          patches =
            builtins.filter
            (p: builtins.match ".*shellscript-crash-fix.*" (toString p) == null)
            (old.patches or []);
        });
      })
      # neofetch (hyfetch's neowofetch) parses vm_stat with a loose
      # `/ wired/` awk pattern; macOS 27 added a "Pages tag-storage non-tag
      # wired:" line that also matches, so pages_wired becomes two lines,
      # the memory arithmetic explodes, and the script dies with exit 1 —
      # silently, because neofetch itself runs `exec 2>/dev/null`.
      # Tighten the pattern to the exact line. Worth reporting upstream to
      # hyfetch.
      # (The yt-dlp/pipx/yubikey-manager FixedFfi migrations that lived
      # here left with the scaffold — plain builds ride the cache again.)
      # The --replace-fail below doubles as a tripwire: hyfetch 2.1.0
      # still ships the old pattern; the release containing our merged
      # fix (hyfetch#526) will make this build FAIL LOUDLY — that's the
      # signal to delete this overlay.
      (final: prev: {
        hyfetch = prev.hyfetch.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              substituteInPlace neofetch \
                --replace-fail "awk '/ wired/ { print \$4 }'" "awk '/Pages wired down/ { print \$4 }'"
            '';
        });
      })
      # (removed 2026-08-22) curl-impersonate fixDarwinDylibNames overlay:
      # our own NixOS/nixpkgs#554592 merged within a day and is in-tree
      # at this pin — the dylib install name is absolute upstream now.
      #
      # nodejs-slim doCheck=false, RE-ADDED 2026-08-22 (same override we
      # retired 2026-07-15 with "re-add only if nodejs must ever be built
      # locally again"): Hydra lags the fresh 26.7.0 drv on this rev, so
      # it builds locally, and parallel/test-dgram-udp6-link-local-address
      # fails — an environment-dependent UDP6 link-local test (Starlink/
      # VPN interface state), not a code defect; nixpkgs' nodejs has no
      # per-test disable knob. REMOVE once Hydra's cache carries nodejs
      # again (the override diverges the drv, forcing local builds).
      (final: prev: {
        nodejs-slim_26 = prev.nodejs-slim_26.overrideAttrs (old: {
          doCheck = false;
        });
      })
      # (removed 2026-07-25) vscode asar-path overlay: upstream fix was
      # our own NixOS/nixpkgs#543899, merged 07-21, in-tree at 6d120041.
      # (removed 2026-07-25) the nixpkgs-stable pin bridge (unar,
      # easylpac, xournalpp, motrix-next): unstable's cache finally
      # carries all four. Pattern for the next cache wave: add a
      # nixos-XX.YY input + one `inherit (inputs.nixpkgs-stable
      # .legacyPackages.${system}) <pkgs>;` overlay. NOTE: local builds
      # still ld-crash on this beta (cctools 1010.6, Trace/BPT trap), so
      # a future wave means re-pinning, not building through.
    ];

    # pkgs with overlays
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
      # Required by androidenv (Android SDK/emulator in home/core.nix).
      config.android_sdk.accept_license = true;
    };

    # my.pkgs = ./pkgs/default.nix
    # NOTE: must use the OVERLAID pkgs, not nixpkgs.legacyPackages —
    # custom packages that wrap or depend on overlay-fixed packages
    # (stable pins, FixedFfi python apps) would otherwise resolve to the
    # broken/uncached plain-unstable variants.
    myPkgs = import ./pkgs {
      inherit lib inputs pkgs;
    };

    # my = ./my/default.nix + myPkgs
    my =
      import ./my
      // {
        pkgs = myPkgs;
      };

    # Special args passed to all modules
    specialArgs =
      inputs
      // {
        inherit inputs pkgs system hostname username useremail my;
      };
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system specialArgs;

      modules = [
        # Generation label: `darwin-rebuild --list-generations` shows
        # "<date>.<commit>" instead of bare numbers, so rollback targets are
        # identifiable. Falls back to "dirty" silently — this tree is often
        # dirty mid-iteration, and a lib.warn here would spam every eval.
        {
          system.configurationRevision = self.rev or null;
          system.darwinLabel =
            if self ? shortRev
            then "${lib.substring 0 8 self.sourceInfo.lastModifiedDate}.${self.shortRev}"
            else "dirty";
        }

        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username} = {
            imports = [
              # inputs.twist.homeModules.emacs-twist
              ./home
            ];
            # programs.emacs-twist = {
            #     enable = true;
            #     emacsclient.enable = true;
            #     createInitFile = true;
            #     config = inputs.emacs-config;
            # };
          };
        }
      ];
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    # TEMPORARY debug handle — remove after libffi investigation
    debugPkgs = pkgs;
    # Debug handle for custom packages: `nix build .#debugMy.pkgs.<name>`
    debugMy = my;
  };
}
