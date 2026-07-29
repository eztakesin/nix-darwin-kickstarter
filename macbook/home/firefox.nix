{
  pkgs,
  lib,
  ...
}: let
  # ── Profile directory name ────────────────────────────────────────────
  # From about:profiles → "Root Directory" (last path component). This is
  # the in-use default profile of Firefox Nightly; two older profiles
  # (lneiea4n.default-release, i0xtei38.default) exist but are inactive
  # and deliberately left unmanaged.
  profileDir = "0ba1cm4u.default-nightly";

  # ── arkenfox user.js (upstream, pinned) ───────────────────────────────
  # Bump: change the tag, run
  #   nix store prefetch-file https://raw.githubusercontent.com/arkenfox/user.js/<tag>/user.js
  # and paste the new hash. Release notes list the pref changes per version.
  arkenfox = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/144.0/user.js";
    hash = "sha256-5KszxpFImRdc9wNeDlei1/CKyIfY+VfxGZ5+Sbvn4z4=";
  };

  # arkenfox first, our overrides second — Firefox applies user_pref in
  # file order, so the last assignment of a pref wins. This replaces
  # arkenfox's updater.sh (which does the same concatenation at runtime).
  userJs = pkgs.concatTextFile {
    name = "firefox-user.js";
    files = [
      arkenfox
      ../dotfiles/firefox/user-overrides.js
    ];
  };
in {
  # Declarative arkenfox, via a bridge symlink.
  #
  # macOS TCC protects ~/Library/Application Support/Firefox, so home-
  # manager cannot write the profile's user.js directly ("Operation not
  # permitted") — and granting the terminal Full Disk Access just to let
  # it would hand every command run there access to *all* protected data
  # (other browser profiles, Mail, Messages, backups). Not a trade worth
  # making for one pref file.
  #
  # Instead nix owns an unprotected file and the profile merely points at
  # it:  <profile>/user.js -> ~/.config/firefox/user.js -> /nix/store/...
  # Every rebuild touches only ~/.config; Firefox follows the chain at
  # startup and always reads the current build.
  #
  # ONE-TIME SETUP (needs FDA only for this single command; revoke right
  # after — see manuals/firefox-arkenfox.md):
  #   ln -s ~/.config/firefox/user.js \
  #     "$HOME/Library/Application Support/Firefox/Profiles/PROFILE/user.js"
  # where PROFILE is the profileDir above.
  #
  # CAVEAT: user.js only *enforces* the prefs it contains. A pref you
  # DELETE from user-overrides.js keeps its last value in prefs.js — to
  # reset those, run arkenfox's prefsCleaner.sh once (with Firefox closed)
  # or use Firefox's "Refresh". Adding/changing prefs needs no such step.
  home.file.".config/firefox/user.js".source = userJs;

  # Firefox UI tweaks. Same bridge pattern: nix owns the file here, the
  # profile's chrome/userChrome.css is a one-time symlink to it. Requires
  # toolkit.legacyUserProfileCustomizations.stylesheets = true, which is
  # set in user-overrides.js (it defaults to false — that is why a
  # hand-placed userChrome.css silently does nothing).
  home.file.".config/firefox/userChrome.css".source = ../dotfiles/firefox/userChrome.css;
}
