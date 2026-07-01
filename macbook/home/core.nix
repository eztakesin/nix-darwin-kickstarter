{
  lib,
  pkgs,
  ...
}: let
  myPython = pkgs.python314.withPackages (ps:
    with ps; [
      aiohttp
      numpy
      pylint
      pyyaml
      requests
      toml
      python-lsp-server
      pylsp-mypy
      pyls-isort
      # python-lsp-black
      pyls-memestra
      pylsp-rope
      python-lsp-ruff
      ipykernel
      epc
      sexpdata
      pyobjc-core
      six
      inflect
      # pyqt6
      pyqt6-sip
    ]);
  lspPackages = with pkgs; [
    # C/c++ language server powered by clang
    ccls
    kotlin-language-server
    # Language server that offers Lua language support
    lua-language-server
    # Opinionated Lua code formatter
    stylua
    # Yet another language server for Nix
    nil
    # Type checker for the Python language
    pyright
    # Language server for the Rust language
    rust-analyzer
    # nodePackages.bash-language-server
    # nodePackages.dockerfile-language-server-nodejs
    # nodePackages.eslint
    # nodePackages.graphql-language-service-cli
    # nodePackages.typescript-language-server
    # nodePackages.yaml-language-server
    yamlfmt
    topiary
    fish-lsp
    vscode-langservers-extracted
  ];

  cliPackages = with pkgs; [
    # Ping, but with a graph
    gping
    # Faster Nmap Scanning with Rust
    rclone
    rustscan
    wget
    # Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster
    claude-code
    # Eclipse Temurin, prebuilt OpenJDK binary
    temurin-bin-26
    # Event-driven I/O framework for the V8 JavaScript engine
    nodejs_26
    # Parser generator tool and an incremental parsing library
    tree-sitter

    # Shell & Terminal
    bat
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batdiff
    bat-extras.batpipe
    bat-extras.batwatch
    bat-extras.prettybat
    lsd
    zellij # tmux 替代（Rust，支持浮动窗格/插件）
    less
    fzf
    figlet
    lolcat
    glow
    trash-cli
    rich-cli
    tailspin
    neovim-remote

    # Development
    gh
    git-lfs
    delta # git-delta
    lazygit
    go
    rustc
    cargo
    cargo-edit
    cargo-outdated
    pipx
    uv
    pnpm
    luarocks
    mkcert
    caddy

    # File & Archive
    ouch # 统一压缩解压（Rust，自动识别格式）
    p7zip
    unar
    unzip
    pngcrush
    poppler-utils
    djvulibre
    librsvg
    imagemagick
    pandoc

    # Text Browsers
    lynx
    w3m

    # Media
    mpv
    gnuplot

    # Container & Virtualization
    qemu

    # AI
    gemini-cli

    # Misc
    gnused
    jaq
    uutils-coreutils
    uutils-diffutils
    uutils-findutils
    clipboard-jh
    ascii-image-converter
  ];
in {
  home.packages = with pkgs;
    [
      myPython # Compiler & interpreters
      # coursera-dl
      nix-prefetch
      deno
      # Modern media player for macOS
      iina
      # Vector graphics editor
      inkscape-with-extensions
      # Full-featured download manager, rebuilt from scratch with Tauri 2, Vue 3, and Rust
      motrix-next
      # TODO: Full-featured e-mail client
      thunderbird
      # zoom.us video conferencing application
      zoom-us
    ]
    ++ lspPackages
    ++ cliPackages;

  # install VS Code via Home Manager
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions;
      [
        rust-lang.rust-analyzer # Advanced Rust language server
        ms-python.python # Core Python support (debugging, IntelliSense, etc.)
        njpwerner.autodocstring # Auto-generates Python docstrings
        ms-toolsai.jupyter-renderers # Rich output renderers for Jupyter
        graphql.vscode-graphql # GraphQL syntax highlighting and tooling
        prisma.prisma # Prisma schema language support
        cweijan.vscode-database-client2 # GUI client for SQL/NoSQL databases
        esbenp.prettier-vscode # Code formatter using Prettier
        davidanson.vscode-markdownlint # Linter for Markdown files
        gencer.html-slim-scss-css-class-completion # Class name auto-completion for HTML/SCSS
        styled-components.vscode-styled-components # Syntax highlighting for styled-components
        gruntfuggly.todo-tree # Highlights TODOs/FIXMEs in a tree view
        pkief.material-icon-theme # Material Design icons for files/folders
        ms-vscode.hexeditor # Hex editor for binary files
        streetsidesoftware.code-spell-checker # Spell checker for source code and comments
        ms-vscode.anycode # Basic IntelliSense for unsupported languages
        wix.vscode-import-cost # Shows size of imported packages inline
        christian-kohler.path-intellisense # Auto-completes file paths in import statements
        alexdima.copy-relative-path # Adds command to copy relative file path
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
          version = "1.32.0";
          sha256 = "sha256-1LlRTkskBAlYV+fq3GVyOUGYXbILvKIByBu2uKwTUUc=";
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
          version = "0.15.0";
          sha256 = "sha256-W31OlLnRK4YECKToeG6gfpnvjbVHt4BToSF01lGwvEM=";
        }
        {
          name = "catppuccin-vsc";
          publisher = "catppuccin";
          version = "3.19.0";
          sha256 = "sha256-6/NHZkg37b6RyZIP89FMltSii+7sC5UTfHYFgyYyl4A=";
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
          version = "3.0.24";
          sha256 = "sha256-ZQVzpSSLf3tpO4QtLjbCOje3L5/EqzT9A9IOssl6e54=";
        }
        {
          name = "binary-plist";
          publisher = "dnicolson";
          version = "2.0.0";
          sha256 = "sha256-d4x6oD5FXPzMhW5wSc+NHDxhq+sIf93l5Vgn/rUDT14=";
        }
        {
          name = "githistory";
          publisher = "donjayamanne";
          version = "0.6.20";
          sha256 = "sha256-nEdYS9/cMS4dcbFje23a47QBZr9eDK3dvtkFWqA+OHU=";
        }
        {
          name = "protobuf-vsc";
          publisher = "drblury";
          version = "1.6.6";
          sha256 = "sha256-uMyxdLptaLZBlLEugvYQgJTZCtysmnZix9faXsQfHGk=";
        }
        {
          name = "editorconfig";
          publisher = "editorconfig";
          version = "0.18.2";
          sha256 = "sha256-y8A3D/IEvBbYSj7mgwU2/AQ1WFb6DolasGThoDz8uEo=";
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
          version = "0.53.1";
          sha256 = "sha256-sgZFI3iWioecvh05bTvT/gJU0zEf79P1xs6vzGkBTWU=";
        }
        {
          name = "vscode-graphql-syntax";
          publisher = "graphql";
          version = "1.3.10";
          sha256 = "sha256-EY6BHl5ICcs3FuuenoadDXLLPSe8+2VAAydqo/YrtaE=";
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
          version = "0.5.9";
          sha256 = "sha256-hPOcp6Yksgfu1+In21/gJ3MthV8JUV5WaRpYHvo5GGk=";
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
          version = "3.24.1";
          sha256 = "sha256-xZpK6pJNXnxudauzJihEi9VASRXi89+hn7vfF33qRgY=";
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
          version = "2026.5.11321003";
          sha256 = "sha256-4p/uKwSHg5HP4qp18eb35Lkb+SDhk4k+oIlEjIqBLOs=";
        }
        {
          name = "debugpy";
          publisher = "ms-python";
          version = "2026.7.11331010";
          sha256 = "sha256-WG6uB+q3qnIw5+RWN/774dL04YSdGCE3bN8fzhjl4ck=";
        }
        {
          name = "isort";
          publisher = "ms-python";
          version = "2026.5.11331015";
          sha256 = "sha256-zXFUMizE6ClEgzpKD/4mYUgOkoYCFHlkzLfcWDAJ/oY=";
        }
        {
          name = "vscode-pylance";
          publisher = "ms-python";
          version = "2026.2.103";
          sha256 = "sha256-6KnX4sLhCVQEoDt7EWmYUeDHiFgp+Jxz51bf29Ho57M=";
        }
        {
          name = "vscode-python-envs";
          publisher = "ms-python";
          version = "1.33.2026051501";
          sha256 = "sha256-V5anlwzLt0V08HsO6TCBIUPD3VPhyohg7YnSc/1++GE=";
        }
        {
          name = "jupyter";
          publisher = "ms-toolsai";
          version = "2025.10.2026051401";
          sha256 = "sha256-bVdHaezdeu+SqjbfHK/6LddRuMkWK9FmSUZz6K8ktXE=";
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
          version = "1.24.15";
          sha256 = "sha256-y0X5D7fgFbMfJg3O3GOxuayCuvI/0otU0QBeeYOrGLk=";
        }
        {
          name = "cpp-devtools";
          publisher = "ms-vscode";
          version = "0.6.1";
          sha256 = "sha256-8Mr5Dob8gBlvr5yBK6RTK/EBeMKBIPc8K2p/HH0O4C0=";
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
          version = "0.39.5";
          sha256 = "sha256-8f9LGmNE8ilPYZmbJpmmAx9DkKJXbQzAia11rM3wTec=";
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
      ];
  };
}
