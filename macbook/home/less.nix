{...}: {
  # Managed here (home-manager) rather than system-level: nix-darwin has no
  # programs.less module (that's NixOS-only),
  # and this is a single-user machine anyway.
  programs.less = {
    enable = true;

    # These land in lesskey's `#env` section, which less gives precedence
    # over an environment $LESS — so tools like man(1) that export their
    # own $LESS can't clobber them.
    options = {
      RAW-CONTROL-CHARS = true; # pass colors through, escape everything else
      mouse = true; # wheel scrolls less itself (hold Shift/Fn to select text)
      wheel-lines = 5;
      LONG-PROMPT = true; # verbose prompt: line numbers / percentage
    };
  };

  # No SYSTEMD_LESS: that's journalctl's pager variable, systemd/Linux only.
  # No lessopen = null either: NixOS enables a lesspipe preprocessor by
  # default; home-manager never sets LESSOPEN.
  home.sessionVariables.PAGER = "less";
}
