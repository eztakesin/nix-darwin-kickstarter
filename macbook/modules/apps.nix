{ pkgs, my, ... }:
{
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  # TODO Fell free to modify this file to fit your needs.
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    fish
    kitty
    starship
    neovim
    git
    just # use Justfile to simplify nix-darwin's commands
    emacs-overlays
  ];
  environment.variables.EDITOR = "nvim";

  environment.shells = with pkgs; [ fish ];

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      # cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # TODO Feel free to add your favorite apps here.

      # Xcode = 497799835;
      FBReader = 1067172178;
    };

    # taps = [];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      # Networking Tools
      "aria2" # Lightweight multi-protocol download utility (HTTP, FTP, BitTorrent)
      "wget" # Command-line file downloader
      "iftop" # Real-time bandwidth monitor
      "mtr" # Network diagnostic tool combining ping and traceroute
      "tcpdump" # Packet analyzer for network traffic
      "qbittorrent-cli" # CLI interface for qBittorrent

      # Shell & Terminal Enhancements
      "fish" # Friendly interactive shell
      "bash-completion@2" # Programmable completion for Bash 4+
      "starship" # Cross-shell customizable prompt
      "lsd" # Modern replacement for ls with icons and colors
      "bat" # cat clone with syntax highlighting and Git integration
      "bat-extras" # Extra tools built around bat (e.g., batgrep, batdiff)
      "tree" # Display directory structure in tree format
      "tmux" # Terminal multiplexer for managing sessions and panes
      "less" # Terminal pager for viewing long output
      "rich-cli" # Render Markdown, JSON, and tables beautifully in the terminal
      "trash-cli" # Move files to trash from the command line
      "fzf" # Command-line fuzzy finder
      "pwgen" # Password generator
      "procs" # Modern replacement for ps with better formatting
      "pv" # Monitor data progress through a pipe
      "figlet" # Create ASCII art text banners
      "lolcat" # Rainbow-colored terminal output
      "glow" # Render Markdown in the terminal
      "neovim-remote" # Remote control interface for Neovim
      "vim" # Classic text editor

      # Development Tools
      "git" # Distributed version control system
      "gh" # GitHub CLI tool
      "git-lfs" # Git extension for versioning large files
      "git-delta" # Syntax-highlighting pager for git diff and git show
      "lazygit" # Simple terminal UI for Git commands
      "go" # Go programming language
      "rust" # Rust programming language
      "gpatch" # GNU patch tool for applying diffs
      "repo" # Google's tool for managing multiple Git repositories
      "pipx" # Install and run Python applications in isolated environments
      "luarocks" # Package manager for Lua modules

      # Language Servers & Formatters
      "bash-language-server" # Language Server Protocol (LSP) for Bash
      "ccls" # C/C++/Objective-C language server
      "dockerfile-language-server" # LSP for Dockerfiles
      "fish-lsp" # Language server for Fish shell scripts
      "lua-language-server" # LSP for Lua
      "stylua" # Code formatter for Lua
      "typescript-language-server" # LSP for TypeScript
      "yaml-language-server" # LSP for YAML
      "yamlfmt" # YAML formatter
      "vscode-langservers-extracted" # LSPs for HTML, CSS, JSON, etc.
      "topiary" # Formatter for tree-sitter-based languages

      # File & Archive Utilities
      "atool" # Archive manager for tar, zip, etc.
      "p7zip" # 7-Zip file archiver with high compression
      "unar" # Extractor for many archive formats
      "unzip" # Extract .zip files
      "lzop" # Fast compression tool similar to gzip
      "lrzip" # Compression tool optimized for large files
      "pngcrush" # Optimize PNG files (lossless compression)
      "rsync" # File sync and transfer tool
      "file-formula" # Determines file type (like the file command)
      "poppler" # PDF rendering library (text/image extraction)
      "djvulibre" # Tools for working with DjVu documents
      "librsvg" # SVG rendering library
      "pandoc" # Universal document converter (Markdown ⇄ PDF/HTML/etc.)

      # System Utilities
      "gdu" # Disk usage analyzer with a TUI interface
      "lsof" # Lists open files and the processes using them
      "smartmontools" # Tools for monitoring and controlling hard drive SMART data
      "usbutils" # Tools for listing USB devices
      "mas" # Mac App Store CLI
      "pcsc-lite" # Middleware for smart card support
      "pinentry-mac" # GUI pin entry dialog for GPG on macOS
      "ykman" # YubiKey Manager CLI
      "ykpers" # YubiKey personalization tool

      # Terminal File Managers
      "ranger" # Terminal file manager with VI keybindings
      "joshuto" # Terminal file manager similar to Ranger

      # Web & Text Browsers
      "lynx" # Text-based web browser
      "w3m" # Text-based web browser with image support

      # Miscellaneous Tools
      "chardet" # Character encoding detector
      "clipboard" # Cross-platform clipboard access from the terminal
      "jaq" # A faster, simpler jq alternative for JSON processing
      "hyfetch" # Customizable neofetch with pride flags and themes
      "tealdeer" # Fast tldr client (simplified man pages)
      "gnu-sed" # GNU version of sed
      "gnuplot" # Command-line graphing utility
      "uutils-coreutils" # Rust-based GNU core utilities alternative
      "uutils-diffutils" # Rust-based diff utilities
      "uutils-findutils" # Rust-based find utilities
      "ripgrep-all" # Like ripgrep, but also searches PDFs, DOCX, etc.

      # Virtualization & Emulation
      "qemu" # Hardware virtualization and emulation tool
      "python"
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "android-platform-tools"
      "aria2d"
      "c0re100-qbittorrent"
      "discord"
      "firefox"
      "font-awesome-terminal-fonts"
      "font-dejavu"
      "font-dejavu-sans-mono-nerd-font"
      "font-fira-code-nerd-font"
      "font-material-symbols"
      "gimp"
      "gnucash"
      "google-chrome"
      "inkscape"
      "iina"
      "iina+"
      "kitty"
      "lyx"
      "mactex"
      "obs"
      "openvisualtraceroute"
      "proton-mail-bridge"
      "steam"
      "thunderbird"
      "xournal++"
      # "visual-studio-code"
      "vlc"
      "battery"
      "nuclear"
      "whisky"
    ];
  };
}