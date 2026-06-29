{
  description = "Nix for macOS configuration";

  nixConfig = {
    substituters = ["https://cache.nixos.org"];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
    useremail = "amatoki@shiohara.me";

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
      (final: prev: {
        python3 = prev.python3.override (old: {
          packageOverrides = pself: psuper: {
            pipx = psuper.pipx.overridePythonAttrs (_: {
              doCheck = false;
            });
          };
        });
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
  };
}
