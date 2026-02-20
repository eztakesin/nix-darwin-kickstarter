{ pkgs, my, ... }:
{
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  CLI tools are primarily managed by Nix (see home/core.nix).
  #  Homebrew is used for: macOS-specific tools, hardware tools,
  #  permission-sensitive network tools, container runtime, and GUI apps.
  #
  ##########################################################################

  # Nix-managed system packages (available to all users, reproducible, rollbackable)
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

  # Homebrew: only for packages that don't work well with Nix on macOS
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      # cleanup = "zap";
    };

    masApps = {
      FBReader = 1067172178;
    };

    # `brew install`
    # Only packages that need to stay on Homebrew:
    # - macOS-specific tools
    # - Hardware/permission-sensitive tools
    # - Container runtime (colima+docker integration)
    # - Packages not available in nixpkgs
    brews = [
      # macOS-Specific
      "mas" # Mac App Store CLI
      "pinentry-mac" # GUI pin entry dialog for GPG on macOS
      "ideviceinstaller" # Install apps on iOS devices
      "bash-completion@2" # Programmable completion for Bash 4+

      # Hardware & Security (better macOS integration via brew)
      "pcsc-lite" # Middleware for smart card support
      "ykman" # YubiKey Manager CLI
      "ykpers" # YubiKey personalization tool

      # Permission-Sensitive Network Tools (brew handles setuid/permissions better)
      "iftop" # Real-time bandwidth monitor
      "tcpdump" # Packet analyzer for network traffic

      # Container Runtime (colima VM integration is macOS-specific)
      "docker" # Container engine
      "docker-compose" # Multi-container orchestration
      "colima" # Lightweight container runtime for macOS (Docker Desktop alternative)

      # Not available in nixpkgs / brew-only
      "julia" # Julia programming language (not available in nixpkgs for aarch64-darwin)
      "qbittorrent-cli" # CLI interface for qBittorrent (not available in nixpkgs for aarch64-darwin)
      "github-markdown-toc" # Generate table of contents for Markdown files
      # pidof: replaced by procs (nix) — use `procs --filter name=xxx`
      "composer" # PHP dependency manager
      "repo" # Google's tool for managing multiple Git repositories
      "gpatch" # GNU patch tool for applying diffs
      "chardet" # Character encoding detector
      "python" # Python (brew version for compatibility)

      # macOS-specific system tools
      "lsof" # Lists open files and the processes using them
      "usbutils" # Tools for listing USB devices
      "vulkan-tools" # Vulkan GPU diagnostic tools
      "xclip" # X11 clipboard CLI
      "xsel" # X11 selection CLI
    ];

    # `brew install --cask`
    # GUI apps are best managed by Homebrew on macOS
    casks = [
      # Browsers
      "firefox"
      "google-chrome"
      "tor-browser"

      # Communication
      "discord"
      "microsoft-teams"
      "zoom"
      "thunderbird"

      # Development
      "claude-code"
      "dbeaver-community"
      "sqlcl"
      "temurin"
      # VS Code is managed by home-manager (see home/core.nix)

      # Media
      "iina"
      "iina+"
      "vlc"
      "nuclear"
      "obs"
      "gstreamer-runtime"

      # Download
      "aria2d"
      "c0re100-qbittorrent"
      "motrix"

      # Productivity & Utilities
      "antigravity"
      "antigravity-tools"
      "inkscape"
      # kitty is managed by nix (environment.systemPackages)
      "lyx"
      "xournal++"
      # openvisualtraceroute: replaced by trippy (nix)
      "protonvpn"
      "sikarugir"
      "steam"

      # Fonts
      "font-awesome-terminal-fonts"
      "font-dejavu"
      "font-dejavu-sans-mono-nerd-font"
      "font-fira-code-nerd-font"
      "font-material-symbols"
      "font-noto-sans-cjk"
      "font-noto-sans-cjk-hk"
      "font-noto-sans-cjk-jp"
      "font-noto-sans-cjk-sc"
      "font-noto-sans-cjk-tc"
      "font-noto-sans-mono-cjk-hk"
      "font-noto-sans-mono-cjk-jp"
      "font-noto-sans-mono-cjk-sc"
      "font-noto-sans-mono-cjk-tc"
      "font-noto-serif-cjk"
      "font-noto-serif-cjk-hk"
      "font-noto-serif-cjk-jp"
      "font-noto-serif-cjk-sc"
      "font-noto-serif-cjk-tc"
      "font-source-han-sans-vf"
      "font-source-han-serif-vf"
      "font-source-sans-3"
    ];
  };
}