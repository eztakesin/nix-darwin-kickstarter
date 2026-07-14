{...}: {
  # TODO: Monitor of resources
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "/Users/macbook/.config/btop/themes/catppuccin_latte.theme";
      rounded_corners = true;
      graph_symbol = "braille";
      graph_symbol_cpu = "braille";
      graph_symbol_gpu = "braille";
      graph_symbol_mem = "braille";
      graph_symbol_net = "braille";
      graph_symbol_proc = "braille";
    };
  };
}
