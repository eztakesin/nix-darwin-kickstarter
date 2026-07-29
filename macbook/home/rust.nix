{
  config,
  pkgs,
  ...
}: let
  # Nightly toolchain from rust-overlay (oxalica's; it repackages the
  # official rust dist binaries, so nothing is compiled locally and no
  # Hydra cache is involved). Pinned by flake.lock — bump with
  # `nix flake update rust-overlay`.
  #
  # selectLatestNightlyWith (rather than a hardcoded date) picks the
  # newest nightly in the locked overlay that actually ships every
  # component requested below; individual nightlies do occasionally miss
  # one, which would otherwise break eval.
  #
  # `default` already bundles rustc/cargo/clippy/rustfmt; the extensions
  # add:
  #   rust-src      — rust-analyzer needs it to navigate into std
  #   llvm-tools    — required by cargo-llvm-cov
  #   rust-analyzer — toolchain-matched LSP: its proc-macro server ABI
  #                   tracks this exact nightly (the nixpkgs build was
  #                   dropped from core.nix in favour of this)
  rustToolchain = pkgs.rust-bin.selectLatestNightlyWith (
    toolchain:
      toolchain.default.override {
        extensions = ["rust-src" "llvm-tools" "rust-analyzer"];
        # wasm32: EVM/blockchain tooling and wasm experiments.
        targets = ["wasm32-unknown-unknown"];
      }
  );
in {
  home.packages = with pkgs; [
    rustToolchain

    # ── cargo subcommands ──
    # Manage dependencies from the command line (cargo add/rm/upgrade)
    cargo-edit
    # Display outdated dependencies
    cargo-outdated
    # Audit Cargo.lock against the RustSec advisory database
    cargo-audit
    # Lint for unused dependencies
    cargo-machete
    # Expand macros to see what they generate
    cargo-expand
    # Coverage reports (needs the llvm-tools extension above)
    cargo-llvm-cov
  ];

  # Cargo's global config. Kept as a plain home.file rather than
  # oxalica's generated-CARGO_HOME-with-symlinks construction: that
  # buys an immutable config at the cost of a fragile store path that
  # has to re-link every mutable cargo dir. CARGO_HOME stays at the
  # default ~/.cargo, so only this one file is nix-managed.
  home.file.".cargo/config.toml".text = ''
    [build]
    # Keep target/ out of project directories — on macOS this also keeps
    # multi-GB build artifacts away from Spotlight indexing and backups.
    # Caveat: tooling that hardcodes ./target needs an explicit path.
    target-dir = "${config.xdg.cacheHome}/cargo/target"

    [resolver]
    # Prefer dependency versions compatible with the project's MSRV.
    incompatible-rust-versions = "fallback"

    [registry]
    # macOS counterpart of oxalica's cargo:libsecret — crates.io tokens
    # live in the login Keychain instead of a plaintext credentials file.
    global-credential-providers = ["cargo:token", "cargo:macos-keychain"]
  '';
}
