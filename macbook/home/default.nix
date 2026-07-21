{
  username,
  config,
  lib,
  ...
}: {
  # import sub modules — one file per program, kitty.nix-style
  imports = [
    ./core.nix
    ./git.nix
    ./gpg.nix
    ./starship.nix
    ./fish.nix
    ./kitty.nix

    ./aria2.nix
    ./bat.nix
    ./btop.nix
    ./eza.nix
    ./fd.nix
    ./gh.nix
    ./htop.nix
    ./hyfetch.nix
    ./joshuto.nix
    ./jq.nix
    ./lazygit.nix
    ./less.nix
    ./neovim.nix
    ./ranger.nix
    ./ripgrep.nix
    ./skim.nix
    ./sops.nix
    ./tealdeer.nix
    ./yazi.nix
    ./yt-dlp.nix
    ./zellij.nix
    ./zoxide.nix
    # emacs: intentionally not enabled — see overlays/emacs.nix and the
    # emacs-config flake input. (was: programs.emacs.package = pkgs.emacs-overlays)
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    file = let
      home = config.home.homeDirectory;
      link = path: config.lib.file.mkOutOfStoreSymlink "${home}/${path}";
      linkPersonal = path: link "storage/personal/${path}";
    in {
      # ".emacs.d" = {
      #   source = ../overlays/emacs;
      #   recursive = true;
      # };

      # aria2 config itself is managed by programs.aria2 (home/aria2.nix,
      # written to ~/.config/aria2/aria2.conf). Only the tracker updater
      # lives in ~/.aria2/ next to aria2's state files; it refreshes the
      # bt-tracker list of the running daemon via RPC.
      ".aria2/trackers-list-aria2.sh" = {
        source = ../dotfiles/aria2/trackers-list-aria2.sh;
        executable = true;
      };
      # Firefox user-overrides.js (for arkenfox)
      # NOTE: After first Firefox launch, you need to:
      # 1. Find your profile dir: about:profiles
      # 2. Clone arkenfox user.js into the profile dir
      # 3. Symlink or copy this file there
      # 4. Run: ./updater.sh && ./prefsCleaner.sh
      ".config/firefox-user-overrides.js" = {
        source = ../dotfiles/firefox/user-overrides.js;
      };

      # Wallpaper
      "Pictures/wallpaper.png" = {
        source = ../dotfiles/wallpapers/wallpaper.png;
      };
    };

    # Add to home managers dag to make sure the activation fails if emacs can't
    # parse the init files and nuke any temp dirs we don't need/want to stick
    # around if present.
    # activation.freshEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   printf "home/default.nix: clean ~/.emacs.d\n" >&2
    #   run rm -rf $VERBOSE_ARG ~/.emacs.d/init.el ~/.emacs.d/init.elc ~/.emacs.d/elpa ~/.emacs.d/eln-cache
    # '';

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "26.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
