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
      # Required by hyfetch 2.x: without it every run stops with "missing field `pride_month_disable`".
      # false = the pride-month animation plays once in June; true = never.
      pride_month_disable = false;
    };
  };
}
