{ username, config, lib, ... }:

{
  # import sub modules
  imports = [
    ./core.nix
    ./git.nix
    ./programs.nix
    ./starship.nix
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
      ".emacs.d" = {
        source = ./emacs;
        recursive = true;
      };
    };

    # Add to home managers dag to make sure the activation fails if emacs can't
    # parse the init files and nuke any temp dirs we don't need/want to stick
    # around if present.
    activation.freshEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      printf "home/default.nix: clean ~/.emacs.d\n" >&2
      run rm -rf $VERBOSE_ARG ~/.emacs.d/init.el ~/.emacs.d/init.elc ~/.emacs.d/elpa ~/.emacs.d/eln-cache
    '';

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}