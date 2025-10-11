{
    description = "Nix for macOS configuration";

    nixConfig = {
        substituters = [ "https://cache.nixos.org" ];
    };

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        darwin = {
            url = "github:lnl7/nix-darwin";
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
        darwin,
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
        my = import ./my // {
            pkgs = myPkgs;
        };

        # Special args passed to all modules
        specialArgs = inputs // {
            inherit inputs pkgs system hostname username useremail my;
        };

    in {
        darwinConfigurations.${hostname} = darwin.lib.darwinSystem {
            inherit system specialArgs;

            modules = [
                ./modules/nix-core.nix
                ./modules/system.nix
                ./modules/apps.nix
                ./modules/host-users.nix

                home-manager.darwinModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
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
    } ;
}