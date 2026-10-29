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
      # (removed 2026-09-30) the python packageOverrides overlay — the
      # last of the cache-miss-era test skips. All four packages ride
      # Hydra's cache again at this pin (python3 = 3.14.7), verified by
      # probing the clean drvs: pipx 1.16.6 and pylsp-mypy 0.8.0 (test
      # suites were broken upstream since 2026-07), python-lsp-ruff 2.3.4
      # (E402 assertions vs newer ruff), and the curl-cffi test_verify
      # mirror of nixpkgs#554405 (curl-cffi 0.16.0 passes its suite).
      # Python package fixes go through `pythonPackagesExtensions`: it
      # patches every python3xxPackages set at once, so python3.pkgs
      # (vscode extensions, pipx's
      # toPythonApplication) and the separate python314 attr that
      # home/core.nix's myPython is built from can't drift apart.
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
      # (removed 2026-10-29) clipboard-jh clang-stdenv overlay: the upstream
      # fix nixpkgs#570577 reached the pin and the clean build is cached.
      # (removed 2026-10-20) debugpy test_lldb_command mirror: nixpkgs#572564
      # reached the pin (hardcode-lldb.patch now updates the test too) and
      # the clean debugpy 1.8.22 is cached again.
      #
      # qbittorrent-enhanced on darwin: Qt 6.12 (nixpkgs 67c8881f, 2026-10-08)
      # marks Q_OS_MAC deprecated, and qBittorrent's -pedantic-errors build
      # turns the two remaining `#ifdef Q_OS_MAC` (log/loglistview.cpp,
      # optionsdialog.cpp; macOS-only code) into hard errors, so Hydra has no
      # darwin build. Mirrors upstream qBittorrent 6164ed1178 ("Replace
      # deprecated Q_OS_MAC macro"), which is on master only — not in 5.2.4
      # nor in Enhanced 5.2.4.10. DROP once the pin's clean
      # qbittorrent-enhanced is cached again.
      (final: prev: {
        qbittorrent-enhanced = prev.qbittorrent-enhanced.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              sed -i -E 's/\bQ_OS_MAC\b/Q_OS_MACOS/' \
                src/gui/log/loglistview.cpp src/gui/optionsdialog.cpp
            '';
        });
      })
      # cargo-llvm-cov 0.9.0: its test suite instruments fixture crates with
      # nixpkgs' rustc and runs them; since rustc 1.98.1 -> 1.99.0 (this pin)
      # those binaries SIGSEGV (14 of 20 tests), and Hydra has no build on
      # darwin or Linux. The package's own header notes the tool keeps working
      # when that happens — real use here goes through the rust-overlay
      # nightly and its llvm-tools, verified with a coverage run. DROP once the
      # pin's clean cargo-llvm-cov is cached again.
      (final: prev: {
        cargo-llvm-cov = prev.cargo-llvm-cov.overrideAttrs {doCheck = false;};
      })
      # (removed 2026-10-20) azure-cli invoke pin, together with azure-cli
      # itself (home/core.nix). nixpkgs bumped invoke to 3.0.3 (c1aaa60e)
      # and marked fabric broken for invoke >= 3 (fabric/fabric#2376), so
      # azure-cli fails evaluation (NixOS/nixpkgs#575989); its appservice
      # module imports fabric and invoke at module level. If azure-cli comes
      # back before that is fixed: a pythonPackagesExtensions overlay that
      # pins invoke to 2.2.1 (fetchPypi, sha256-UVv0m0pIkyt5sCRZA0jaIvOcSULf
      # +ZGtH7i4uuob5wc=) only where `pyfinal ? azure-cli-core`, i.e. inside
      # azure-cli's private python set. Pinning only fabric's invoke clashes
      # with the one paramiko propagates (pythonCatchConflictsHook), and a
      # global pin rebuilds every paramiko dependent that is otherwise cached.
      # (removed 2026-08-22) curl-impersonate fixDarwinDylibNames overlay:
      # our own NixOS/nixpkgs#554592 merged within a day and is in-tree
      # at this pin — the dylib install name is absolute upstream now.
      #
      # (removed 2026-09-30, second retirement) nodejs-slim doCheck=false:
      # Hydra carries the clean nodejs-slim 26.10.0 at this pin. It was
      # re-added 2026-08-22 only because 26.7.0 lagged the cache and
      # parallel/test-dgram-udp6-link-local-address fails on this
      # machine's IPv6 link-local state (Starlink/VPN) — re-add the same
      # override if nodejs ever has to build locally again.
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
