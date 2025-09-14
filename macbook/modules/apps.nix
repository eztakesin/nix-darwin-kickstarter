{ pkgs, ... }:
{
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  # TODO Fell free to modify this file to fit your needs.
  #
  ##########################################################################

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    fish
    kitty
    starship
    neovim
    git
    just # use Justfile to simplify nix-darwin's commands
  ];
  environment.variables.EDITOR = "nvim";

  environment.shells = with pkgs; [ fish ];

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      # cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # TODO Feel free to add your favorite apps here.

      # Xcode = 497799835;
      FBReader = 1067172178;
    };

    # taps = [];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "android-platform-tools"
      "aria2d"
      "c0re100-qbittorrent"
      "discord"
      "firefox"
      "font-awesome-terminal-fonts"
      "font-dejavu"
      "font-dejavu-sans-mono-nerd-font"
      "font-fira-code-nerd-font"
      "font-material-symbols"
      "gimp"
      "gnucash"
      "google-chrome"
      "inkscape"
      "iina"
      "iina+"
      "kitty"
      "lyx"
      "mactex"
      "obs"
      "openvisualtraceroute"
      "proton-mail-bridge"
      "steam"
      "thunderbird"
      "xournal++"
      # "visual-studio-code"
      "vlc"
    ];
  };
}