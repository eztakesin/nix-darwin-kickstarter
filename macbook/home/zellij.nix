{...}: {
  # Terminal workspace (tmux replacement). Settings are written to
  # ~/.config/zellij/config.kdl (KDL — the config.yaml the option docs
  # mention only applies to zellij < 0.32).
  programs.zellij = {
    enable = true;

    # These AUTO-START zellij in every interactive shell (via
    # `zellij setup --generate-auto-start`), not just completions.
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    # tmux-parity notes (reference config used tmux):
    #   splits:      Ctrl-p then r / d      (vs tmux bind v / s)
    #   move focus:  Alt-h/j/k/l built in   (vs tmux bind C-h/j/k/l)
    #   resize:      Alt-+ / Alt--          (vs tmux bind H/J/K/L)
    #   base-index / terminal-overrides: not needed — tabs are 1-based
    #   and zellij manages its own terminfo handling.
    settings = {
      # Ships built-in since zellij 0.42 (catppuccin/zellij repo is only
      # for older versions) — matches the btop/kitty latte look.
      theme = "catppuccin-latte";

      # tmux: set -g mouse on
      mouse_mode = true;
      # tmux: historyLimit = 100000
      scroll_buffer_size = 100000;
      # tmux: copy-selection-no-clear on mouse release
      copy_on_select = true;
      # tmux: set-clipboard on — but write the macOS clipboard directly
      # instead of relying on OSC52 passthrough.
      copy_command = "pbcopy";

      # Don't show the startup tips popup on every session.
      show_startup_tips = false;
    };
  };
}
