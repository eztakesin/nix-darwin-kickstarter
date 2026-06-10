{
  pkgs,
  my,
  ...
}: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  CLI tools are primarily managed by Nix (see home/core.nix).
  #  Homebrew is used for: macOS-specific GUI apps (casks), the container
  #  runtime, and a few formulae not (yet) usable via Nix on aarch64-darwin.
  #
  ##########################################################################

  # Nix-managed system packages (available to all users, reproducible, rollbackable)
  environment.systemPackages = with pkgs; [
    fish
    kitty
    starship
    neovim
    git
    alejandra
    # gnupg              # moved to home-manager (home/gpg.nix → programs.gpg.enable)
    # pinentry_mac       # owned by home/gpg.nix via home.packages
    # just # use Justfile to simplify nix-darwin's commands
    # emacs-overlays
    easylpac

    # ── Migrated from Homebrew formulae ──────────────────────────────────────
    # Nix does NOT select bottles by macOS version, so these install fine on the
    # macOS 27 pre-release — where the brew formulae fail with ":dunno" (a failure
    # that `brew update-reset` / `--build-from-source` do not fix).
    gnupatch # was brew: gpatch — provides `patch` (GNU), NOT a `gpatch` binary
    gitRepo # was brew: repo (Google's multi-repo tool)
    lsof # was brew: lsof
    python3Packages.chardet # was brew: chardet — provides the `chardetect` CLI
    phpPackages.composer # was brew: composer (pulls in PHP as a runtime dep)
    mas # was brew: mas (Mac App Store CLI; darwin-only package)
    ideviceinstaller # was brew: ideviceinstaller (install apps on iOS devices)
    iftop # was brew: iftop — run as `sudo iftop` (needs pcap; Nix can't setuid the store)
    tcpdump # was brew: tcpdump — run as `sudo tcpdump`
    yubikey-manager # was brew: ykman — provides `ykman`.
    # ^ If you hit a YubiKey "card error" after rebuild, the Nix build's PCSC
    #   linkage may differ from brew's — just move `ykman` back to brews if so.
    yubikey-personalization # was brew: ykpers — provides `ykpersonalize`
    aria2 # the aria2c CLI downloader (NOT a replacement for the aria2d GUI cask)
  ];
  environment.variables.EDITOR = "nvim";

  # NOTE: environment.shells is defined once in system.nix (next to
  # programs.fish.enable) — do not also set it here, or it merges to a duplicate.

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
      # FBReader = 1067172178;
    };

    # `brew install`
    # NOTE (macOS 27 pre-release): Homebrew has no bottles for this OS yet, so the
    # formulae below still fail with ":dunno". `brew update-reset` did not help
    # (macOS 27 support not shipped yet) and ":dunno" can't be worked around with
    # --build-from-source. They stay here until Homebrew adds macOS 27 support, OR
    # get migrated to Nix where an aarch64-darwin package exists.
    brews = [
      # Installs fine even now — architecture-independent (":all") bottle:
      # "bash-completion@2" # Programmable completion for Bash 4+

      # Container stack: also broken on macOS 27, and also exists in nixpkgs for
      # darwin — but migrating means setting up the Lima VM under Nix too, so it's
      # left here for now (ask to migrate the whole stack together).
      # "docker" # Container engine
      # "docker-compose" # Multi-container orchestration
      # "colima" # Lightweight container runtime (Docker Desktop alternative)

      # No clean Nix path on aarch64-darwin → wait for Homebrew macOS 27 support:
      # "julia" # NOTE: do NOT --build-from-source (compiles LLVM — hours, many GB)
      # "qbittorrent-cli" # not packaged in nixpkgs for aarch64-darwin
      # "python" # kept for brew compatibility (use Nix `python3` if you prefer)
      # Dropped (were broken on macOS 27 with no good darwin path):
      #   usbutils     — Linux-only (lsusb/sysfs); on macOS use `system_profiler SPUSBDataType` or `ioreg -p IOUSB`
      #   vulkan-tools — removed
      # "github-markdown-toc" # Generate table of contents for Markdown files

      # Migrated to Nix (see environment.systemPackages above):
      #   mas, ideviceinstaller, ykman→yubikey-manager, ykpers→yubikey-personalization,
      #   iftop, tcpdump, and earlier: gpatch, repo, lsof, chardet, composer.
      # pidof: replaced by procs (nix) — use `procs --filter name=xxx`
      # X11-only (no-op on macOS without XQuartz):
      # "xclip"
      # "xsel"
    ];

    # `brew install --cask`
    # Casks just download apps/installers — they do NOT use version-keyed bottles,
    # so NONE of these are affected by the macOS 27 ":dunno" problem; they install
    # fine as-is. (firefox / google-chrome / thunderbird are also Linux-only in
    # nixpkgs and won't build on darwin, so cask is the correct choice regardless.)
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
      # "dbeaver-community"
      # "sqlcl"
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
      # "antigravity-tools"
      "inkscape"
      # kitty is managed by nix (environment.systemPackages)
      # "lyx"
      "xournal++"
      # openvisualtraceroute: replaced by trippy (nix)
      "protonvpn"
      # "sikarugir"
      # "steam"

      # Fonts
      # NOTE: Most fonts moved to Nix — see system.nix `fonts.packages`.
      # The following stay on Homebrew: no confirmed standalone nixpkgs package.
      # (font-material-symbols is Google's Material Symbols, distinct from the
      #  pictogrammers material-design-icons already in fonts.packages.)
      "font-awesome-terminal-fonts"
      "font-material-symbols"
      "font-klee-one"
      "font-yusei-magic"
    ];
  };
}
