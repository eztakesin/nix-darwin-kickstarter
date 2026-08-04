{
  pkgs,
  my,
  ...
}: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  CLI tools are primarily managed by Nix.
  #  Homebrew is used for: macOS-specific GUI apps (casks), the container
  #  runtime, and a few formulae not (yet) usable via Nix on aarch64-darwin.
  #
  ##########################################################################

  # Nix-managed system packages (available to all users, reproducible, rollbackable)
  environment.systemPackages = with pkgs; [
    # fish itself is installed by programs.fish.enable (system.nix) — the
    # nix-darwin module adds it to systemPackages, which keeps the login
    # shell path /run/current-system/sw/bin/fish valid.
    # kitty + neovim/git/fd/ripgrep/jq/starship are managed by home-manager
    # programs.* modules (home/) — do not also list them here. kitty.app is
    # the real copy in ~/Applications/Home Manager Apps (pin the Dock icon
    # from there, not /Applications/Nix Apps).
    alejandra
    # pinentry_mac       # owned by home/gpg.nix via home.packages
    # just # use Justfile to simplify nix-darwin's commands
    # emacs-overlays

    # ── Migrated from Homebrew formulae ──────────────────────────────────────
    # Nix does NOT select bottles by macOS version, so these install fine on the
    # macOS 27 pre-release — where the brew formulae fail with ":dunno" (a failure
    # that `brew update-reset` / `--build-from-source` do not fix).
    gnupatch # was brew: gpatch — provides `patch` (GNU), NOT a `gpatch` binary
    gitRepo # was brew: repo (Google's multi-repo tool)
    python3Packages.chardet # was brew: chardet — provides ta` CLI
    phpPackages.composer # was brew: composer (pulls in PHP as a runtime dep)
    mas # was brew: mas (Mac App Store CLI; darwin-only package)
    ideviceinstaller # was brew: ideviceinstaller (install apps on iOS devices)
    tcpdump # was brew: tcpdump — run as `sudo tcpdump`
    yubikey-manager # was brew: ykman — provides `ykman`.
    # ^ If you hit a YubiKey "card error" after rebuild, the Nix build's PCSC
    #   linkage may differ from brew's — just move `ykman` back to brews if so.
    yubikey-personalization # was brew: ykpers — provides `ykpersonalize`

    # Modern replacement for ps written in Rust
    procs
    # du, but more intuitive
    dust
    # Tools for monitoring the health of hard drives
    smartmontools
    # Collection of programs for inspecting and manipulating configuration of PCI devices
    pciutils
    # Tools for working with USB devices, such as lsusb
    usbutils

    # Growing collection of the unix tools that nobody thought to write long ago when unix was young
    moreutils
    # curl 替代, Friendly and fast tool for sending HTTP requests
    xh
    # Tool for monitoring the progress of data through a pipeline
    pv
    # Command to produce a depth indented directory listing
    tree
    # Tool to list open files
    lsof
    # GNU software calculator
    bc
    # Program that shows the type of files
    file
    # Fast incremental file transfer utility
    rsync
    # Domain name server
    dnsutils
    # Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation
    gnupg
    # Modern encryption tool with small explicit keys
    age
    # age identities on YubiKey PIV slots (decrypt = card + PIN + touch);
    # must be on PATH for sops/age to find the plugin. See
    # manuals/sops-mnemonic.md for the full mnemonic-encryption workflow.
    age-plugin-yubikey
    # Password generator which creates passwords which can be easily memorized by a human
    pwgen
    # Simple and flexible tool for managing secrets
    sops
    # Convert ssh private keys in ed25519 format to age keys
    ssh-to-age

    # Multi-format archive and compression library
    libarchive
    # Zstandard real-time compression algorithm
    zstd
    # Tool for creating and unpacking squashfs filesystems
    squashfsTools

    # iftop 替代, CLI utility for displaying current network utilization
    bandwhich
    # mtr 替代, Network diagnostics tool
    trippy
    # wireshark (GUI) lives in home.packages so the .app gets a real copy in
    # ~/Applications (Spotlight-indexed); it bundles the full CLI (tshark,
    # dumpcap, …) — wireshark-cli and tshark are the same nixpkgs package
    # and were redundant. Capture still needs sudo (no ChmodBPF).
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

    # Third-party taps. Needed for casks that are not in homebrew-cask
    # core; nix-darwin runs `brew tap` for these before installing.
    # (removed 2026-07-30) sikarugir-app/sikarugir — Sikarugir fully
    # uninstalled today (incl. the CS2.app wrapper); keeping the tap+cask
    # here would silently reinstall it on the next darwin-rebuild switch.
    taps = [];

    brews = [
      "docker" # Container engine
      # "docker-compose" # Multi-container orchestration
      "colima" # Lightweight container runtime (Docker Desktop alternative)

      "python" # kept for brew compatibility (use Nix `python3` if you prefer)
      "github-markdown-toc" # Generate table of contents for Markdown files
    ];

    # `brew install --cask`
    # Casks just download apps/installers — they do NOT use version-keyed bottles,
    # so NONE of these are affected by the macOS 27 ":dunno" problem; they install
    # fine as-is. (firefox / google-chrome / thunderbird are also Linux-only in
    # nixpkgs and won't build on darwin, so cask is the correct choice regardless.)
    casks = [
      # Browsers
      "firefox@nightly"
      "google-chrome@canary"
      "tor-browser"

      # Communication
      "discord@canary"
      "microsoft-teams"

      # Media
      "gstreamer-runtime"
      "obs"
      "vlc"

      # Desktop publishing — nixpkgs scribus is meta.broken on
      # aarch64-darwin (and uncached); the cask ships the official
      # upstream binary.
      "scribus"

      # Development
      # "dbeaver-community"
      # "sqlcl"
      # VS Code is managed by home-manager (see home/core.nix)
      "claude" # Claude Desktop app

      "protonvpn"
      # (removed 2026-07-30) sikarugir-app/sikarugir/sikarugir — see the
      # taps note above. GPTK4 work now self-compiles wine instead
      # (~/Workspace/gptk4-engine-builder, isolated x86_64 brew).
      # Kept for reference: prl_naptd (the firewall prompt after running a
      # Windows VM) belongs to Parallels' shared-network NAT/DHCP daemon
      # and must stay allowed for VM networking to work.
      # "steam"
      "battle-net"

      # Fonts
      # NOTE: Most fonts moved to Nix — see system.nix `fonts.packages`.
      # The following stay on Homebrew: no confirmed standalone nixpkgs package.
      # (font-material-symbols is Google's Material Symbols, distinct from the
      # material-design-icons already in fonts.packages.)
      "font-material-symbols"
      "font-klee-one"
      "font-yusei-magic"
      "font-material-design-icons-webfont"
      "font-noto-sans-mono"
      "font-source-sans-3"
    ];
  };
}
