{
    description = "Nix for macOS configuration";

    ##################################################################################################################
    #
    # Want to know Nix in details? Looking for a beginner-friendly tutorial?
    # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
    #
    ##################################################################################################################

    # the nixConfig here only affects the flake itself, not the system configuration!
    nixConfig = {
        substituters = [
            # Query the the official cache.
            "https://cache.nixos.org"
        ];
    };

    # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
    # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        darwin = {
            url = "github:lnl7/nix-darwin/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # home-manager, used for managing user configuration
        home-manager = {
            url = "github:nix-community/home-manager";
            # The `follows` keyword in inputs is used for inheritance.
            # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
            # to avoid problems caused by different versions of nixpkgs dependencies.
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
    };

    # The `outputs` function will return all the build results of the flake.
    # A flake can have many use cases and different types of outputs,
    # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
    # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
    # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
    outputs = inputs @ {
        self,
        nixpkgs,
        darwin,
        home-manager,
        darwin-emacs,
        darwin-emacs-packages,
        ...
    }: let
        # TODO replace with your own username, email, system, and hostname
        username = "macbook";
        useremail = "amatoki@shiohara.me";
        system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
        hostname = "macbook";

        overlays = [
            darwin-emacs.overlays.emacs
            darwin-emacs-packages.overlays.package
        ];

        pkgs = import nixpkgs {
            system = system;
            overlays = overlays;
            config.allowUnfree = true;
        };

        specialArgs =
            inputs
            // {
                inherit pkgs username useremail hostname;
            };
    in {
        darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
            ./modules/nix-core.nix
            ./modules/system.nix
            ./modules/apps.nix
            # ./modules/homebrew-mirror.nix # comment this line if you don't need a homebrew mirror
            ./modules/host-users.nix

            # home manager
            home-manager.darwinModules.home-manager
            {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = specialArgs;
                home-manager.users.${username} = import ./home;
            }
        ];
    };

        # nix code formatter
        formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}