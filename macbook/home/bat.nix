{
  pkgs,
  ...
}: {
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Latte";
    };
  };
}
