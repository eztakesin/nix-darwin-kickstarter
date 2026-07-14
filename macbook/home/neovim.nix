{pkgs, ...}: {
  # modern vim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # false: this would pull nixpkgs' default nodejs (24) into the closure
    # as the node provider, duplicating the nodejs_26 pinned in core.nix.
    # No node-based nvim plugins are in use; re-enable if one appears.
    withNodeJs = false;
    withPython3 = true;
    withRuby = true;
    extraPackages = with pkgs; [
      neovim-remote
    ];
  };
}
