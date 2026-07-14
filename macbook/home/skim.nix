{...}: {
  # Command-line fuzzy finder written in Rust — the fuzzy finder of this
  # config; owns Ctrl-R/Ctrl-T in all shells (fzf stays uninstalled).
  # fzf intentionally not enabled: skim (below) is the fuzzy finder here —
  # it owns the Ctrl-R/Ctrl-T keybindings and fish.nix aliases fzf to sk.
  programs.skim = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };
}
