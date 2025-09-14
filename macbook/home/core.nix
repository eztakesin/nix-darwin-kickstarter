{
  lib,
  pkgs,
  ...
}: let
  myPython = pkgs.python312.withPackages (ps:
    with ps; [
      # aiohttp
      # numpy
      # pylint
      # pyyaml
      # requests
      # toml
      python-lsp-server
      pylsp-mypy
      pyls-isort
      # python-lsp-black
      pyls-memestra
      pylsp-rope
      python-lsp-ruff
      ipykernel
    ]);
  lspPackages = with pkgs; [
    rust-analyzer
    nil # rnix-lsp
    pyright
    kotlin-language-server
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.eslint
    nodePackages.graphql-language-service-cli
    nodePackages.typescript-language-server
    nodePackages.unified-language-server
    nodePackages.yaml-language-server
  ];
in {
  home.packages = with pkgs;
    [
      myPython # Compiler & interpreters
      coursera-dl
      nix-prefetch
    ]
    ++ lspPackages;

  # install VS Code via Home Manager
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions;
      [
        rust-lang.rust-analyzer                  # Advanced Rust language server
        ms-python.python                         # Core Python support (debugging, IntelliSense, etc.)
        njpwerner.autodocstring                  # Auto-generates Python docstrings
        ms-toolsai.jupyter-renderers             # Rich output renderers for Jupyter
        graphql.vscode-graphql                   # GraphQL syntax highlighting and tooling
        prisma.prisma                            # Prisma schema language support
        cweijan.vscode-database-client2          # GUI client for SQL/NoSQL databases
        esbenp.prettier-vscode                   # Code formatter using Prettier
        davidanson.vscode-markdownlint           # Linter for Markdown files
        gencer.html-slim-scss-css-class-completion # Class name auto-completion for HTML/SCSS
        styled-components.vscode-styled-components # Syntax highlighting for styled-components
        gruntfuggly.todo-tree                    # Highlights TODOs/FIXMEs in a tree view
        pkief.material-icon-theme                # Material Design icons for files/folders
        ms-vscode.hexeditor                      # Hex editor for binary files
        streetsidesoftware.code-spell-checker    # Spell checker for source code and comments
        ms-vscode.anycode                        # Basic IntelliSense for unsupported languages
        wix.vscode-import-cost                   # Shows size of imported packages inline
        christian-kohler.path-intellisense       # Auto-completes file paths in import statements
        alexdima.copy-relative-path              # Adds command to copy relative file path
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # bbenoist.nix                             # Basic syntax highlighting for Nix
        # jnoortheen.nix-ide                       # Full IDE support for Nix
        # kamadorueda.alejandra                    # Formatter for Nix using Alejandra
        # golang.go                                # Official Go extension with full tooling
        # zxh404.vscode-proto3                     # Protocol Buffers (.proto) support
        # ms-python.vscode-pylance                 # Fast Python language server with type checking
        # ms-python.isort                          # Automatically sorts Python imports
        # ms-python.black-formatter                # Formats Python code using Black
        # ms-toolsai.jupyter                       # Jupyter notebook support
        # ms-toolsai.jupyter-keymap                # Jupyter keyboard shortcuts
        # tamasfe.even-better-toml                 # TOML support with formatting and validation
        # zainchen.json                            # JSON formatting and validation tools
        # ms-vscode.cmake-tools                    # CMake support for C++ projects
        # timonwong.shellcheck                     # Shell script linting with ShellCheck
        # foxundermoon.shell-format                # Formatter for shell scripts
        # editorconfig.editorconfig                # Enforces .editorconfig settings
        # dbaeumer.vscode-eslint                   # JavaScript/TypeScript linting with ESLint
        # donjayamanne.githistory                  # View Git file history and logs
        # mhutchie.git-graph                       # Visual Git graph viewer
        # codezombiech.gitignore                   # .gitignore support with templates
        # oderwat.indent-rainbow                   # Colorizes indentation levels
        # shardulm94.trailing-spaces               # Highlights trailing whitespace
        # mechatroner.rainbow-csv                  # Colorizes CSV/TSV files
        # yzhang.markdown-all-in-one               # All-in-one Markdown support
        # bierner.markdown-checkbox                # Checkbox support in Markdown
        # bierner.markdown-mermaid                 # Mermaid diagram support in Markdown
        # bradlc.vscode-tailwindcss                # IntelliSense and linting for Tailwind CSS
        # catppuccin.catppuccin-vsc                # Catppuccin color theme
        # bierner.emojisense                       # Emoji auto-completion
        # irongeek.vscode-env                      # Syntax highlighting and support for .env files
        # eg2.vscode-npm-script                    # Run/manage npm scripts from VSCode
        # firefox-devtools.vscode-firefox-debug    # Debug web apps using Firefox
        # bodil.file-browser                       # File browser sidebar
        # rioj7.commandonallfiles                  # Run commands on all files in workspace
        {
          name = "nix";
          publisher = "bbenoist";
          version = "1.0.1";
          sha256 = "sha256-qwxqOGublQeVP2qrLF94ndX/Be9oZOn+ZMCFX1yyoH0=";
        }
        {
          name = "emojisense";
          publisher = "bierner";
          version = "0.10.0";
          sha256 = "sha256-PD8edYuJu6QHPYIM08kV85LuKh0H0/MIgFmMxSJFK5M=";
        }
        {
          name = "markdown-checkbox";
          publisher = "bierner";
          version = "0.4.0";
          sha256 = "sha256-AoPcdN/67WOzarnF+GIx/nans38Jan8Z5D0StBWIbkk=";
        }
        {
          name = "markdown-mermaid";
          publisher = "bierner";
          version = "1.28.0";
          sha256 = "sha256-NAQD6DK1c13nA/O0QHNxFraImE6C0+Jzj9+f06EkiW0=";
        }
        {
          name = "file-browser";
          publisher = "bodil";
          version = "0.2.11";
          sha256 = "sha256-yPVhhsAUZxnlhj58fXkk+yhxop2q7YJ6X4W9dXGKJfo=";
        }
        {
          name = "vscode-tailwindcss";
          publisher = "bradlc";
          version = "0.14.26";
          sha256 = "sha256-agntfMsLAYASviH7Wuw/W8JwfHRi6qAfuMkqmFWT0bg=";
        }
        {
          name = "catppuccin-vsc";
          publisher = "catppuccin";
          version = "3.18.0";
          sha256 = "sha256-57c0HRdEABLz03qozeQgFJH1NaWUbA+7tDJv0V4At8M=";
        }
        {
          name = "gitignore";
          publisher = "codezombiech";
          version = "0.10.0";
          sha256 = "sha256-WTKVHrhBeAocP+stskFsSFtd0aR3u1TTEMYtdxj1tlY=";
        }
        {
          name = "vscode-eslint";
          publisher = "dbaeumer";
          version = "3.0.19";
          sha256 = "sha256-rpYgvo5H1RBviV5L/pfDWqVXIYaZonRiqh4TLFGEODw=";
        }
        {
          name = "githistory";
          publisher = "donjayamanne";
          version = "0.6.20";
          sha256 = "sha256-nEdYS9/cMS4dcbFje23a47QBZr9eDK3dvtkFWqA+OHU=";
        }
        {
          name = "editorconfig";
          publisher = "editorconfig";
          version = "0.17.4";
          sha256 = "sha256-MYPYhSKAxgaZ0UijxU+xiO4HDPLtXGymhN+2YmTev8M=";
        }
        {
          name = "vscode-npm-script";
          publisher = "eg2";
          version = "0.3.29";
          sha256 = "sha256-k6DtmhYBj7mg8SUU3pg+ezRzWvhiECqYQVj9LDhhV4I=";
        }
        {
          name = "vscode-firefox-debug";
          publisher = "firefox-devtools";
          version = "2.15.0";
          sha256 = "sha256-hBj0V42k32dj2gvsNStUBNZEG7iRYxeDMbuA15AYQqk=";
        }
        {
          name = "shell-format";
          publisher = "foxundermoon";
          version = "7.2.8";
          sha256 = "sha256-Z3vmRzqPCxkQbn39I54bh/ND+0HcE9iFUhKQ29GRd7o=";
        }
        {
          name = "go";
          publisher = "golang";
          version = "0.51.0";
          sha256 = "sha256-aZ60+PHDnYwPxuEDtS5otjxFIs4d3J7hw12xblb8ujY=";
        }
        {
          name = "vscode-env";
          publisher = "irongeek";
          version = "0.1.0";
          sha256 = "sha256-URq90lOFtPCNfSIl2NUwihwRQyqgDysGmBc3NG7o7vk=";
        }
        {
          name = "nix-ide";
          publisher = "jnoortheen";
          version = "0.4.22";
          sha256 = "sha256-j3V03Aa1mHO9rny3/hXmDbs3fmruqyzNzwFjiOlnaMU=";
        }
        {
          name = "alejandra";
          publisher = "kamadorueda";
          version = "1.0.0";
          sha256 = "sha256-COlEjKhm8tK5XfOjrpVUDQ7x3JaOLiYoZ4MdwTL8ktk=";
        }
        {
          name = "rainbow-csv";
          publisher = "mechatroner";
          version = "3.21.0";
          sha256 = "sha256-IPgPE5vM9tzHPioRBZeJs4hqut6t++SjZJlHnz/ismA=";
        }
        {
          name = "git-graph";
          publisher = "mhutchie";
          version = "1.30.0";
          sha256 = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
        }
        {
          name = "black-formatter";
          publisher = "ms-python";
          version = "2025.3.11831009";
          sha256 = "sha256-FsJHxYHae1NuDXQfOJ4TPnXDy05tTuyCElHD4MiaMDU=";
        }
        {
          name = "isort";
          publisher = "ms-python";
          version = "2025.1.12271015";
          sha256 = "sha256-AaHhcre3t758C22mEMjA7fT/egWzcDG/TDQCINhF8Rw=";
        }
        {
          name = "vscode-pylance";
          publisher = "ms-python";
          version = "2025.7.104";
          sha256 = "sha256-PQq6N6BVJr55TN91xVrI9ikjLBXWOZqU8hWYzivFJTk=";
        }
        {
          name = "jupyter";
          publisher = "ms-toolsai";
          version = "2025.8.2025082701";
          sha256 = "sha256-iwyl/59C56UdBD+wxyBMDjd/epr0gLaMDXV8btuICco=";
        }
        {
          name = "jupyter-keymap";
          publisher = "ms-toolsai";
          version = "1.1.2";
          sha256 = "sha256-9BLyBZzZ0Z6QQ05QSxFJYNZmZDc5O3eYkCxe/UsmKws=";
        }
        {
          name = "vscode-jupyter-cell-tags";
          publisher = "ms-toolsai";
          version = "0.1.9";
          sha256 = "sha256-XODbFbOr2kBTzFc0JtjiDUcCDBX1Hd4uajlil7mhqPY=";
        }
        {
          name = "vscode-jupyter-slideshow";
          publisher = "ms-toolsai";
          version = "0.1.6";
          sha256 = "sha256-fnsMrrcYdz6BzUWMd9pAOQGTjmtEbQeoVYG20VWxCsM=";
        }
        {
          name = "cmake-tools";
          publisher = "ms-vscode";
          version = "1.22.9";
          sha256 = "sha256-49zRJSH0mEff8I19QedLH/TdlfL7O8n08meZMEJVabs=";
        }
        {
          name = "indent-rainbow";
          publisher = "oderwat";
          version = "8.3.1";
          sha256 = "sha256-dOicya0B2sriTcDSdCyhtp0Mcx5b6TUaFKVb0YU3jUc=";
        }
        {
          name = "commandonallfiles";
          publisher = "rioj7";
          version = "0.6.0";
          sha256 = "sha256-fPN1bQY96a0bnuq3OeUQTeI67uvPFYPnE6+fKYngUcU=";
        }
        {
          name = "trailing-spaces";
          publisher = "shardulm94";
          version = "0.4.1";
          sha256 = "sha256-pLE1bfLRxjlm/kgU9nmtiPBOnP05giQnWq6bexrrIZY=";
        }
        {
          name = "even-better-toml";
          publisher = "tamasfe";
          version = "0.21.2";
          sha256 = "sha256-IbjWavQoXu4x4hpEkvkhqzbf/NhZpn8RFdKTAnRlCAg=";
        }
        {
          name = "shellcheck";
          publisher = "timonwong";
          version = "0.38.3";
          sha256 = "sha256-qDispRN7jRIIsP+5lamyR+sNoOwTwl+55QftzO7WBm4=";
        }
        {
          name = "markdown-all-in-one";
          publisher = "yzhang";
          version = "3.6.3";
          sha256 = "sha256-xJhbFQSX1DDDp8iE/R8ep+1t5IRusBkvjHcNmvjrboM=";
        }
        {
          name = "json";
          publisher = "zainchen";
          version = "2.0.2";
          sha256 = "sha256-nC3Q8KuCtn/jg1j/NaAxWGvnKe/ykrPm2PUjfsJz8aI=";
        }
        {
          name = "vscode-proto3";
          publisher = "zxh404";
          version = "0.5.5";
          sha256 = "sha256-Em+w3FyJLXrpVAe9N7zsHRoMcpvl+psmG1new7nA8iE=";
        }
      ];
  };
}