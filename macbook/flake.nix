{
  description = "Nix for macOS configuration";

  nixConfig = {
    substituters = ["https://cache.nixos.org"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Fallback for packages whose unstable rebuild isn't on Hydra's
    # aarch64-darwin cache yet (or fails to build locally on the macOS
    # pre-release) — see the overlays list.
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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
      # deno checkPhase bug: test target named "integration_test" not "integration_tests"
      (final: prev: {
        deno = prev.deno.overrideAttrs (old: {doCheck = false;});
      })
      # jeepney: installCheckPhase requires dbus which is unavailable on macOS
      (final: prev: {
        python313Packages = prev.python313Packages.override {
          overrides = pfinal: pprev: {
            jeepney = pprev.jeepney.overrideAttrs (old: {
              doInstallCheck = false;
              pythonImportsCheck = [];
            });
          };
        };
      })
      # pipx: upstream tests assert on PEP 508 spec whitespace ("nox@URL" vs
      # "nox @ URL"); breaks with newer packaging lib. Skip checks.
      # Must override at the python3 interpreter level: `pkgs.pipx` is
      # `python3.pkgs.toPythonApplication python3.pkgs.pipx`, so the
      # checkPhase runs inside `python3.pkgs.pipx`, not the top-level
      # wrapper. Overriding `pkgs.pipx` only patches the wrapper.
      (final: prev: let
        packageOverrides = pself: psuper: {
          pipx = psuper.pipx.overridePythonAttrs (_: {
            doCheck = false;
          });
          # pylsp-mypy: upstream tests assert on mypy's error text; newer
          # mypy prepends a "Python 3.9 is not supported" notice, breaking
          # the regex match. Skip tests.
          pylsp-mypy = psuper.pylsp-mypy.overridePythonAttrs (_: {
            doCheck = false;
          });
        };
      in {
        python3 = prev.python3.override (old: {inherit packageOverrides;});
        # python314 is a separate attr from python3 — home/core.nix builds
        # myPython from it, so it needs the same overrides.
        python314 = prev.python314.override (old: {inherit packageOverrides;});

        # Interpreter linked against upstream libffi: the Apple libffi fork
        # (darwin's default, libffi-40 — Apple has published nothing newer)
        # aborts in trampoline allocation the moment python does
        # `import ctypes` on this macOS 27 pre-release:
        #   Assertion failed: (trampoline_handle),
        #   ffi_trampoline_table_alloc_block_invoke, closures.c:258
        # Upstream libffi (libffiReal, 3.5.2) is verified working.
        #
        # Deliberately a SEPARATE attr instead of overriding python3/python314:
        # the global python3 participates in toolchain builds (clang, llvm,
        # apple-sdk, stdenv bootstrap), so swapping its libffi invalidates the
        # entire binary cache — a 2600-derivation world rebuild. This attr is
        # used only where ctypes must work at runtime: myPython (home/core.nix,
        # which is also the `python3` on PATH). Drop once nixpkgs ships a
        # fixed libffi.
        # Apple's libffi fork relinked without chained fixups: macOS 27's
        # dyld rejects the trampoline dylib cctools ld produces ("chained
        # fixups, seg_count exceeds number of segments"); -no_fixup_chains
        # makes it loadable again. Verified with dlopen + a minimal
        # ffi_closure_alloc test. Kept as the Apple fork (not libffiReal):
        # cffi/pyobjc historically misbehave with upstream libffi on darwin.
        libffiAppleFixed = final.libffi.overrideAttrs (old: {
          pname = (old.pname or "libffi") + "-nofixupchains";
          NIX_LDFLAGS = (old.NIX_LDFLAGS or "") + " -no_fixup_chains";
        });

        # Mandatory extras beyond swapping `libffi` (all learned the hard way):
        #  - recursive `self`: without it the overridden interpreter's
        #    .pkgs/.withPackages still resolve through the ORIGINAL
        #    python314's package set, silently producing envs built on the
        #    unpatched interpreter.
        #  - `pythonAttr`: cpython resolves its BUILD-time interpreters via
        #    pkgsBuildHost.${pythonAttr}; left at "python314" the package
        #    set executes setup.py with the unpatched python, and any build
        #    that imports ctypes (e.g. forbiddenfruit) hits the same abort.
        #  - packageOverrides for cffi and pyobjc-core: both link libffi
        #    DIRECTLY (cffi via its `libffi` input, pyobjc-core via a
        #    hardcoded `darwin.libffi`) — the interpreter's libffi never
        #    reaches them.
        python314FixedFfi = final.python314.override {
          libffi = final.libffiAppleFixed;
          self = final.python314FixedFfi;
          pythonAttr = "python314FixedFfi";
          packageOverrides = prev.lib.composeExtensions packageOverrides (pself: psuper: {
            cffi = psuper.cffi.override {libffi = final.libffiAppleFixed;};
            pyobjc-core = psuper.pyobjc-core.override {
              darwin = final.darwin // {libffi = final.libffiAppleFixed;};
            };
            # FSEvents on the macOS 27 beta delivers an extra file-opened
            # event, tripping exactly one timing-sensitive watchmedo test
            # (126 others pass). Unrelated to libffi.
            watchdog = psuper.watchdog.overridePythonAttrs (old: {
              disabledTests =
                (old.disabledTests or [])
                ++ ["test_auto_restart_not_happening_on_file_opened_event"];
            });
            # RLIMIT_NOFILE semantics changed on the macOS 27 beta; the
            # fd-limit unit test asserts the old value (217 others pass).
            virtualenv = psuper.virtualenv.overridePythonAttrs (old: {
              disabledTests =
                (old.disabledTests or [])
                ++ ["test_too_many_open_files"];
            });
            # Subprocess stdio pause/resume ordering differs on the macOS 27
            # beta; one delayed-stdio test asserts the old behaviour
            # (404 others pass).
            uvloop = psuper.uvloop.overridePythonAttrs (old: {
              disabledTests =
                (old.disabledTests or [])
                ++ ["test_process_delayed_stdio__not_paused__no_stdin"];
            });
          });
        };
      })
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
      # nodejs: the build's checkPhase runs the full `test-ci-js` suite;
      # test-net-autoselectfamily and test-dgram-send-cb-quelches-error need
      # networking that the build sandbox lacks, so they fail. The actual
      # compile + tests live in nodejs-slim_26 (nodejs_26 just symlinks its
      # outputs), so disable the check there.
      (final: prev: {
        nodejs-slim_26 = prev.nodejs-slim_26.overrideAttrs (_: {doCheck = false;});
      })
      # Packages whose unstable (clang-21/apple-sdk-14.4 stdenv) rebuild
      # isn't on Hydra's aarch64-darwin cache yet AND fail to build locally
      # on the macOS 27 pre-release:
      #   unar, easylpac, mpv — old cctools ld crashes at link time (Trace/BPT trap)
      #   nodejs — configure aborts in libffi trampoline allocation
      #   xournalpp, qbittorrent-enhanced, motrix-next — untested locally,
      #     preemptively pinned to cached stable builds (same rebuild wave)
      # Take the cached builds from the stable input; drop entries once
      # unstable's are cached again.
      (final: prev: {
        inherit
          (inputs.nixpkgs-stable.legacyPackages.${system})
          unar
          nodejs_26
          nodejs-slim_26
          easylpac
          mpv-unwrapped
          xournalpp
          qbittorrent-enhanced
          motrix-next
          ;
      })
    ];

    # pkgs with overlays
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

    # my.pkgs = ./pkgs/default.nix
    myPkgs = import ./pkgs {
      inherit lib inputs;
      pkgs = nixpkgs.legacyPackages.${system};
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
  };
}
