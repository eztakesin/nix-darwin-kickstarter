{
  pkgs,
  lib,
  ...
}: {
  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code Nerd Font";
      size = 12;
    };

    settings = {
      # Cursor
      cursor = "#3D2B5A";

      # Scrollback
      scrollback_lines = 10000;

      # Bell
      enable_audio_bell = "no";

      # Window
      confirm_os_window_close = 0;

      # Colors
      foreground = "#7E3462";
      background = "#F6F2EE";
      background_opacity = "1";
      selection_foreground = "#BAB5BF";
      selection_background = "#3E2B5A";

      # Black
      color0 = "#1e1e1e";
      color8 = "#444b6a";

      # Red
      color1 = "#f7768e";
      color9 = "#ff7a93";

      # Green
      color2 = "#69c05c";
      color10 = "#9ece6a";

      # Yellow
      color3 = "#ffcc99";
      color11 = "#ffbd49";

      # Blue
      color4 = "#3a8fff";
      color12 = "#66ccff";

      # Magenta
      color5 = "#9ea0dd";
      color13 = "#c89bb9";

      # Cyan
      color6 = "#0aaab3";
      color14 = "#56b6c2";

      # White
      color7 = "#bfc2da";
      color15 = "#d2d7ff";

      # Shell integration
      shell_integration = "no-sudo";

      # macOS specific
      macos_window_resizable = "yes";
      macos_colorspace = "displayp3";
      clipboard_control = "write-clipboard read-clipboard";
    };

    # Nerd Font symbol maps
    extraConfig = ''
      # https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points
      symbol_map U+E5FA-U+E6B5 Symbols Nerd Font Mono
      # Devicons
      symbol_map U+e700-U+e7c5 Symbols Nerd Font Mono
      # Font Awesome
      symbol_map U+ed00-U+f2ff Symbols Nerd Font Mono
      # Font Awesome Extension
      symbol_map U+e200-U+e2a9 Symbols Nerd Font Mono
      # Material Design Icons
      symbol_map U+f0001-U+f1af0 Symbols Nerd Font Mono
      # Weather
      symbol_map U+e300-U+e3e3 Symbols Nerd Font Mono
      # Octicons
      symbol_map U+f400-U+f533 Symbols Nerd Font Mono
      symbol_map U+2665 Symbols Nerd Font Mono
      symbol_map U+26A1 Symbols Nerd Font Mono
      # Powerline Symbols
      symbol_map U+e0a0-U+e0a2 Symbols Nerd Font Mono
      symbol_map U+e0b0-U+e0b3 Symbols Nerd Font Mono
      # Powerline Extra Symbols
      symbol_map U+e0b4-U+e0c8 Symbols Nerd Font Mono
      symbol_map U+e0cc-U+e0d7 Symbols Nerd Font Mono
      symbol_map U+e0a3 Symbols Nerd Font Mono
      symbol_map U+e0ca Symbols Nerd Font Mono
      # IEC Power Symbols
      symbol_map U+23fb-U+23fe Symbols Nerd Font Mono
      symbol_map U+2b58 Symbols Nerd Font Mono
      # Font Logos
      symbol_map U+f300-U+f375 Symbols Nerd Font Mono
      # Pomicons
      symbol_map U+e000-U+e00a Symbols Nerd Font Mono
      # Codicons
      symbol_map U+ea60-U+ec1e Symbols Nerd Font Mono
      # Heavy Angle Brackets
      symbol_map U+276c-U+2771 Symbols Nerd Font Mono
      # Box Drawing
      symbol_map U+2500-U+259f Symbols Nerd Font Mono
    '';
  };
}
