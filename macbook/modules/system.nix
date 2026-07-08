{
  pkgs,
  my,
  ...
}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://nix-darwin.github.io/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://github.com/yannbertrand/macos-defaults
#
###################################################################################
{
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  system = {
    stateVersion = 6;

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      # Customize dock
      dock = {
        autohide = true;
        show-recents = false; # disable recent apps

        # Customize Hot Corners(触发角, 鼠标移动到屏幕角落时触发的动作)
        # wvous-tl-corner = 2;  # top-left - Mission Control
        # wvous-tr-corner = 13;  # top-right - Lock Screen
        # wvous-bl-corner = 3;  # bottom-left - Application Windows
        # wvous-br-corner = 4;  # bottom-right - Desktop
      };

      # Customize finder
      finder = {
        _FXShowPosixPathInTitle = true; # Show full path in finder title
        AppleShowAllExtensions = true; # Show all file extensions
        FXEnableExtensionChangeWarning = false; # Disable warning when changing file extension
        QuitMenuItem = true; # Enable quit menu item
        ShowPathbar = true; # Show path bar
        ShowStatusBar = true; # Show status bar
      };

      # Customize trackpad
      trackpad = {
        # Tap - 轻触触摸板, Click - 点击触摸板
        # Clicking = true;  # Enable tap to click(轻触触摸板相当于点击)
        TrackpadRightClick = true; # enable two finger right click
        TrackpadThreeFingerDrag = true; # enable three finger drag
      };

      # Customize settings that not supported by nix-darwin directly
      # Incomplete list of macOS `defaults` commands :
      #   https://github.com/yannbertrand/macos-defaults
      NSGlobalDomain = {
        # `defaults read NSGlobalDomain "xxx"`
        "com.apple.swipescrolldirection" = true; # Enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0; # Disable beep sound when pressing volume up/down key
        AppleInterfaceStyle = null; # Dark mode
        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = true; # Enable press and hold

        # If you press and hold certain keyboard keys when in a text area, the key’s character begins to repeat.
        # This is very useful for vim users, they use `hjkl` to move cursor.
        # Sets how long it takes before it starts repeating.
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        # Sets how fast it repeats once it starts.
        KeyRepeat = 3; # Normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        NSAutomaticCapitalizationEnabled = false; # Disable auto capitalization(自动大写)
        NSAutomaticDashSubstitutionEnabled = false; # Disable auto dash substitution(智能破折号替换)
        NSAutomaticPeriodSubstitutionEnabled = false; # Disable auto period substitution(智能句号替换)
        NSAutomaticQuoteSubstitutionEnabled = false; # Disable auto quote substitution(智能引号替换)
        NSAutomaticSpellingCorrectionEnabled = false; # Disable auto spelling correction(自动拼写检查)
        NSNavPanelExpandedStateForSaveMode = true; # Expand save panel by default(保存文件时的路径选择/文件名输入页)
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          # Automatically switch to a new space when switching to the application
          AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          # ShowHardDrivesOnDesktop = true;
          # ShowMountedServersOnDesktop = true;
          # ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.spaces" = {
          "spans-displays" = 0; # Display have seperate spaces
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
          StandardHideDesktopIcons = 1; # Hide items on desktop
          HideDesktop = 1; # Hide items on desktop & stage manager
          StageManagerHideWidgets = 1;
          StandardHideWidgets = 1;
        };
        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.screencapture" = {
          location = "~/Pictures";
          type = "png";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
      };

      loginwindow = {
        GuestEnabled = false; # Disable guest user
        SHOWFULLNAME = true; # Show full name in login window
      };
    };

    # keyboard settings is not very useful on macOS
    # the most important thing is to remap option key to alt key globally,
    # but it's not supported by macOS yet.
    keyboard = {
      enableKeyMapping = true; # enable key mapping so that we can use `option` as `control`

      # NOTE: do NOT support remap capslock to both control and escape at the same time
      # remapCapsLockToControl = false;  # remap caps lock to control, useful for emac users
      # remapCapsLockToEscape  = true;   # remap caps lock to escape, useful for vim users

      # swap left command and left alt
      # so it matches common keyboard layout: `ctrl | command | alt`
      #
      # disabled, caused only problems!
      swapLeftCommandAndLeftAlt = false;
    };
  };

  programs.fish.enable = true;
  environment.shells = [
    pkgs.fish
  ];

  # Fonts
  fonts = {
    packages = with pkgs; [
      material-design-icons

      # nerdfonts
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable-small/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      # nerd-fonts.iosevka / iosevka-term / SGr-IosevkaFixed removed
      # 2026-07: unreferenced by any config, and their 216 faces pushed the
      # font count past what MS Office can enumerate (its "unable to load
      # all your fonts" limit).
      nerd-fonts.dejavu-sans-mono # was cask: font-dejavu-sans-mono-nerd-font

      # CJK & general fonts (migrated from Homebrew casks)
      # NOTE: bare `fira-code` and `jetbrains-mono` are covered by the
      # nerd-fonts.* variants above. Both are dropped here because plain
      # `jetbrains-mono` pulls in afdko, whose test suite fails on macOS 27.
      dejavu_fonts

      # noto-fonts (the global-scripts pack) removed 2026-07: unreferenced,
      # 229 files incl. 93 variable fonts Office handles poorly; macOS
      # system fonts cover common scripts, Noto CJK below covers CJK.
      # NOT noto-fonts-cjk-{sans,serif}(-static): all nixpkgs variants ship
      # CFF collections (.ttc/OTC), which MS Office cannot parse — see the
      # comment in pkgs/noto-cjk-otf.nix. This custom package provides the
      # same "Noto Sans/Serif CJK JP/SC" families as single OTFs instead.
      my.pkgs.noto-cjk-otf
      noto-fonts-color-emoji
      # Free substitutes for Windows Japanese fonts (ＭＳ (Ｐ)ゴシック /
      # ＭＳ 明朝) in non-Office apps. Note MS Office doesn't need these:
      # it bundles the real MS fonts privately in its DFonts folder.
      # BIZ UD(P)Gothic is Morisawa's MS-Office-tuned Gothic substitute;
      # IPAex covers Mincho (BIZ UD Mincho is not in nixpkgs).
      biz-ud-gothic
      ipaexfont
      font-awesome
      hanazono
      # Roman for PDF.
      liberation_ttf
      fira-code
      fira-code-symbols
      # source-han-{sans,serif,mono} intentionally omitted: nixpkgs ships
      # them as CFF super-OTCs (SourceHanSans.ttc etc.), which MS Office
      # cannot parse (same issue as the variable Noto CJK OTCs above), and
      # their glyphs are identical to the Noto CJK static packages — Source
      # Han and Noto CJK are the same typefaces under different family names.
      source-han-code-jp
      wqy_microhei
      wqy_zenhei
      # Only the Mono SC family (what Firefox references) — the full
      # sarasa-gothic ships 480 faces; see pkgs/sarasa-mono-sc.nix.
      my.pkgs.sarasa-mono-sc
      arphic-ukai
      arphic-uming
      unfonts-core
    ];
  };
}
