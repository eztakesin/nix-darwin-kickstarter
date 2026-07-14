{...}: {
  # TODO: Neofetch with LGBTQ+ pride flags
  programs.hyfetch = {
    enable = true;
    settings = {
      preset = "transgender";
      mode = "rgb";
      light_dark = "dark";
      color_align = {
        mode = "horizontal";
      };
      backend = "neofetch";
    };
  };
}
