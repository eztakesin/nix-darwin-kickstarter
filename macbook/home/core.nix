{pkgs, ...}: {
  home.packages = with pkgs; [
    coursera-dl
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      git = true;
      colors = "always";
      icons = "always";
      enableFishIntegration = true;
      theme = {
        colourful = true;

        filekinds = {
          normal = { foreground = "#BAC2DE"; };
          directory = { foreground = "#89B4FA"; };
          symlink = { foreground = "#89DCEB"; };
          pipe = { foreground = "#7F849C"; };
          block_device = { foreground = "#EBA0AC"; };
          char_device = { foreground = "#EBA0AC"; };
          socket = { foreground = "#585B70"; };
          special = { foreground = "#CBA6F7"; };
          executable = { foreground = "#A6E3A1"; };
          mount_point = { foreground = "#74C7EC"; };
        };

        perms = {
          user_read = { foreground = "#CDD6F4"; };
          user_write = { foreground = "#F9E2AF"; };
          user_execute_file = { foreground = "#A6E3A1"; };
          user_execute_other = { foreground = "#A6E3A1"; };
          group_read = { foreground = "#BAC2DE"; };
          group_write = { foreground = "#F9E2AF"; };
          group_execute = { foreground = "#A6E3A1"; };
          other_read = { foreground = "#A6ADC8"; };
          other_write = { foreground = "#F9E2AF"; };
          other_execute = { foreground = "#A6E3A1"; };
          special_user_file = { foreground = "#CBA6F7"; };
          special_other = { foreground = "#585B70"; };
          attribute = { foreground = "#A6ADC8"; };
        };

        size = {
          major = { foreground = "#A6ADC8"; };
          minor = { foreground = "#89DCEB"; };
          number_byte = { foreground = "#CDD6F4"; };
          number_kilo = { foreground = "#BAC2DE"; };
          number_mega = { foreground = "#89B4FA"; };
          number_giga = { foreground = "#CBA6F7"; };
          number_huge = { foreground = "#CBA6F7"; };
          unit_byte = { foreground = "#A6ADC8"; };
          unit_kilo = { foreground = "#89B4FA"; };
          unit_mega = { foreground = "#CBA6F7"; };
          unit_giga = { foreground = "#CBA6F7"; };
          unit_huge = { foreground = "#74C7EC"; };
        };

        users = {
          user_you = { foreground = "#CDD6F4"; };
          user_root = { foreground = "#F38BA8"; };
          user_other = { foreground = "#CBA6F7"; };
          group_yours = { foreground = "#BAC2DE"; };
          group_other = { foreground = "#7F849C"; };
          group_root = { foreground = "#F38BA8"; };
        };

        links = {
          normal = { foreground = "#89DCEB"; };
          multi_link_file = { foreground = "#74C7EC"; };
        };

        git = {
          new = { foreground = "#A6E3A1"; };
          modified = { foreground = "#F9E2AF"; };
          deleted = { foreground = "#F38BA8"; };
          renamed = { foreground = "#94E2D5"; };
          typechange = { foreground = "#F5C2E7"; };
          ignored = { foreground = "#7F849C"; };
          conflicted = { foreground = "#EBA0AC"; };
        };

        git_repo = {
          branch_main = { foreground = "#CDD6F4"; };
          branch_other = { foreground = "#CBA6F7"; };
          git_clean = { foreground = "#A6E3A1"; };
          git_dirty = { foreground = "#F38BA8"; };
        };

        security_context = {
          colon = { foreground = "#7F849C"; };
          user = { foreground = "#BAC2DE"; };
          role = { foreground = "#CBA6F7"; };
          typ = { foreground = "#585B70"; };
          range = { foreground = "#CBA6F7"; };
        };

        file_type = {
          image = { foreground = "#F9E2AF"; };
          video = { foreground = "#F38BA8"; };
          music = { foreground = "#A6E3A1"; };
          lossless = { foreground = "#94E2D5"; };
          crypto = { foreground = "#585B70"; };
          document = { foreground = "#CDD6F4"; };
          compressed = { foreground = "#F5C2E7"; };
          temp = { foreground = "#EBA0AC"; };
          compiled = { foreground = "#74C7EC"; };
          build = { foreground = "#585B70"; };
          source = { foreground = "#89B4FA"; };
        };

        punctuation = { foreground = "#7F849C"; };
        date = { foreground = "#F9E2AF"; };
        inode = { foreground = "#A6ADC8"; };
        blocks = { foreground = "#9399B2"; };
        header = { foreground = "#CDD6F4"; };
        octal = { foreground = "#94E2D5"; };
        flags = { foreground = "#CBA6F7"; };

        symlink_path = { foreground = "#89DCEB"; };
        control_char = { foreground = "#74C7EC"; };
        broken_symlink = { foreground = "#F38BA8"; };
        broken_path_overlay = { foreground = "#585B70"; };
      };
    };

    # terminal file manager
    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
        theme = {
          mgr = {
            cwd = { fg = "#179299"; };

            hovered = { fg = "#eff1f5"; bg = "#40a02b"; };
            preview_hovered = { fg = "#eff1f5"; bg = "#4c4f69"; };

            find_keyword = { fg = "#df8e1d"; italic = true; };
            find_position = { fg = "#ea76cb"; bg = "reset"; italic = true; };

            marker_copied = { fg = "#40a02b"; bg = "#40a02b"; };
            marker_cut = { fg = "#d20f39"; bg = "#d20f39"; };
            marker_marked = { fg = "#179299"; bg = "#179299"; };
            marker_selected = { fg = "#40a02b"; bg = "#40a02b"; };

            count_copied = { fg = "#eff1f5"; bg = "#40a02b"; };
            count_cut = { fg = "#eff1f5"; bg = "#d20f39"; };
            count_selected = { fg = "#eff1f5"; bg = "#40a02b"; };

            border_symbol = "│";
            border_style = { fg = "#8c8fa1"; };

            syntect_theme = "~/.config/bat/themes/Catppuccin-latte.tmTheme";
          };

          tabs = {
            active = { fg = "#eff1f5"; bg = "#4c4f69"; bold = true; };
            inactive = { fg = "#4c4f69"; bg = "#bcc0cc"; };
          };

          mode = {
            normal_main = { fg = "#eff1f5"; bg = "#40a02b"; bold = true; };
            normal_alt = { fg = "#40a02b"; bg = "#ccd0da"; };

            select_main = { fg = "#eff1f5"; bg = "#40a02b"; bold = true; };
            select_alt = { fg = "#40a02b"; bg = "#ccd0da"; };

            unset_main = { fg = "#eff1f5"; bg = "#dd7878"; bold = true; };
            unset_alt = { fg = "#dd7878"; bg = "#ccd0da"; };
          };

          status = {
            sep_left = { open = ""; close = ""; };
            sep_right = { open = ""; close = ""; };

            progress_label = { fg = "#ffffff"; bold = true; };
            progress_normal = { fg = "#1e66f5"; bg = "#bcc0cc"; };
            progress_error = { fg = "#d20f39"; bg = "#bcc0cc"; };

            perm_type = { fg = "#1e66f5"; };
            perm_read = { fg = "#df8e1d"; };
            perm_write = { fg = "#d20f39"; };
            perm_exec = { fg = "#40a02b"; };
            perm_sep = { fg = "#8c8fa1"; };
          };

          input = {
            border = { fg = "#40a02b"; };
            title = { };
            value = { };
            selected = { reversed = true; };
          };

          pick = {
            border = { fg = "#40a02b"; };
            active = { fg = "#ea76cb"; };
            inactive = { };
          };

          confirm = {
            border = { fg = "#40a02b"; };
            title = { fg = "#40a02b"; };
            content = { };
            list = { };
            btn_yes = { reversed = true; };
            btn_no = { };
          };

          cmp = {
            border = { fg = "#40a02b"; };
          };

          tasks = {
            border = { fg = "#40a02b"; };
            title = { };
            hovered = { underline = true; };
          };

          which = {
            mask = { bg = "#ccd0da"; };
            cand = { fg = "#179299"; };
            rest = { fg = "#7c7f93"; };
            desc = { fg = "#ea76cb"; };
            separator = "  ";
            separator_style = { fg = "#acb0be"; };
          };

          help = {
            on = { fg = "#179299"; };
            run = { fg = "#ea76cb"; };
            desc = { fg = "#7c7f93"; };
            hovered = { bg = "#acb0be"; bold = true; };
            footer = { fg = "#4c4f69"; bg = "#bcc0cc"; };
          };

          notify = {
            title_info = { fg = "#179299"; };
            title_warn = { fg = "#df8e1d"; };
            title_error = { fg = "#d20f39"; };
          };

          icon = {
            files = [
              { name = "kritadisplayrc"; text = ""; fg = "#ea76cb"; }
              { name = ".gtkrc-2.0"; text = ""; fg = "#eff1f5"; }
              { name = "bspwmrc"; text = ""; fg = "#4c4f69"; }
              { name = "webpack"; text = "󰜫"; fg = "#209fb5"; }
              { name = "tsconfig.json"; text = ""; fg = "#209fb5"; }
              { name = ".vimrc"; text = ""; fg = "#40a02b"; }
              { name = "gemfile$"; text = ""; fg = "#d20f39"; }
              { name = "xmobarrc"; text = ""; fg = "#e64553"; }
              { name = "avif"; text = ""; fg = "#7c7f93"; }
              { name = "fp-info-cache"; text = ""; fg = "#eff1f5"; }
              { name = ".zshrc"; text = ""; fg = "#40a02b"; }
              { name = "robots.txt"; text = "󰚩"; fg = "#6c6f85"; }
              { name = "dockerfile"; text = "󰡨"; fg = "#7287fd"; }
              { name = ".git-blame-ignore-revs"; text = ""; fg = "#fe640b"; }
              { name = ".nvmrc"; text = ""; fg = "#40a02b"; }
              { name = "hyprpaper.conf"; text = ""; fg = "#209fb5"; }
              { name = ".prettierignore"; text = ""; fg = "#7287fd"; }
              { name = "rakefile"; text = ""; fg = "#d20f39"; }
              { name = "code_of_conduct"; text = ""; fg = "#e64553"; }
              { name = "cmakelists.txt"; text = ""; fg = "#dce0e8"; }
              { name = ".env"; text = ""; fg = "#df8e1d"; }
              { name = "copying.lesser"; text = ""; fg = "#40a02b"; }
              { name = "readme"; text = "󰂺"; fg = "#eff1f5"; }
              { name = "settings.gradle"; text = ""; fg = "#1e66f5"; }
              { name = "gruntfile.coffee"; text = ""; fg = "#fe640b"; }
              { name = ".eslintignore"; text = ""; fg = "#8839ef"; }
              { name = "kalgebrarc"; text = ""; fg = "#04a5e5"; }
              { name = "kdenliverc"; text = ""; fg = "#04a5e5"; }
              { name = ".prettierrc.cjs"; text = ""; fg = "#7287fd"; }
              { name = "cantorrc"; text = ""; fg = "#04a5e5"; }
              { name = "rmd"; text = ""; fg = "#209fb5"; }
              { name = "vagrantfile$"; text = ""; fg = "#1e66f5"; }
              { name = ".Xauthority"; text = ""; fg = "#fe640b"; }
              { name = "prettier.config.ts"; text = ""; fg = "#7287fd"; }
              { name = "node_modules"; text = ""; fg = "#e64553"; }
              { name = ".prettierrc.toml"; text = ""; fg = "#7287fd"; }
              { name = "build.zig.zon"; text = ""; fg = "#df8e1d"; }
              { name = ".ds_store"; text = ""; fg = "#4c4f69"; }
              { name = "PKGBUILD"; text = ""; fg = "#04a5e5"; }
              { name = ".prettierrc"; text = ""; fg = "#7287fd"; }
              { name = ".bash_profile"; text = ""; fg = "#40a02b"; }
              { name = ".npmignore"; text = ""; fg = "#e64553"; }
              { name = ".mailmap"; text = "󰊢"; fg = "#fe640b"; }
              { name = ".codespellrc"; text = "󰓆"; fg = "#40a02b"; }
              { name = "svelte.config.js"; text = ""; fg = "#fe640b"; }
              { name = "eslint.config.ts"; text = ""; fg = "#8839ef"; }
              { name = "config"; text = ""; fg = "#7c7f93"; }
              { name = ".gitlab-ci.yml"; text = ""; fg = "#e64553"; }
              { name = ".gitconfig"; text = ""; fg = "#fe640b"; }
              { name = "_gvimrc"; text = ""; fg = "#40a02b"; }
              { name = ".xinitrc"; text = ""; fg = "#fe640b"; }
              { name = "checkhealth"; text = "󰓙"; fg = "#04a5e5"; }
              { name = "sxhkdrc"; text = ""; fg = "#4c4f69"; }
              { name = ".bashrc"; text = ""; fg = "#40a02b"; }
              { name = "tailwind.config.mjs"; text = "󱏿"; fg = "#209fb5"; }
              { name = "ext_typoscript_setup.txt"; text = ""; fg = "#df8e1d"; }
              { name = "commitlint.config.ts"; text = "󰜘"; fg = "#179299"; }
              { name = "py.typed"; text = ""; fg = "#df8e1d"; }
              { name = ".nanorc"; text = ""; fg = "#4c4f69"; }
              { name = "commit_editmsg"; text = ""; fg = "#fe640b"; }
              { name = ".luaurc"; text = ""; fg = "#04a5e5"; }
              { name = "fp-lib-table"; text = ""; fg = "#eff1f5"; }
              { name = ".editorconfig"; text = ""; fg = "#eff1f5"; }
              { name = "justfile"; text = ""; fg = "#7c7f93"; }
              { name = "kdeglobals"; text = ""; fg = "#04a5e5"; }
              { name = "license.md"; text = ""; fg = "#df8e1d"; }
              { name = ".clang-format"; text = ""; fg = "#7c7f93"; }
              { name = "docker-compose.yaml"; text = "󰡨"; fg = "#7287fd"; }
              { name = "copying"; text = ""; fg = "#40a02b"; }
              { name = "go.mod"; text = ""; fg = "#209fb5"; }
              { name = "lxqt.conf"; text = ""; fg = "#04a5e5"; }
              { name = "brewfile"; text = ""; fg = "#d20f39"; }
              { name = "gulpfile.coffee"; text = ""; fg = "#d20f39"; }
              { name = ".dockerignore"; text = "󰡨"; fg = "#7287fd"; }
              { name = ".settings.json"; text = ""; fg = "#8839ef"; }
              { name = "tailwind.config.js"; text = "󱏿"; fg = "#209fb5"; }
              { name = ".clang-tidy"; text = ""; fg = "#7c7f93"; }
              { name = ".gvimrc"; text = ""; fg = "#40a02b"; }
              { name = "nuxt.config.cjs"; text = "󱄆"; fg = "#40a02b"; }
              { name = "xsettingsd.conf"; text = ""; fg = "#fe640b"; }
              { name = "nuxt.config.js"; text = "󱄆"; fg = "#40a02b"; }
              { name = "eslint.config.cjs"; text = ""; fg = "#8839ef"; }
              { name = "sym-lib-table"; text = ""; fg = "#eff1f5"; }
              { name = ".condarc"; text = ""; fg = "#40a02b"; }
              { name = "xmonad.hs"; text = ""; fg = "#e64553"; }
              { name = "tmux.conf"; text = ""; fg = "#40a02b"; }
              { name = "xmobarrc.hs"; text = ""; fg = "#e64553"; }
              { name = ".prettierrc.yaml"; text = ""; fg = "#7287fd"; }
              { name = ".pre-commit-config.yaml"; text = "󰛢"; fg = "#df8e1d"; }
              { name = "i3blocks.conf"; text = ""; fg = "#e6e9ef"; }
              { name = "xorg.conf"; text = ""; fg = "#fe640b"; }
              { name = ".zshenv"; text = ""; fg = "#40a02b"; }
              { name = "vlcrc"; text = "󰕼"; fg = "#fe640b"; }
              { name = "license"; text = ""; fg = "#df8e1d"; }
              { name = "unlicense"; text = ""; fg = "#df8e1d"; }
              { name = "tmux.conf.local"; text = ""; fg = "#40a02b"; }
              { name = ".SRCINFO"; text = "󰣇"; fg = "#04a5e5"; }
              { name = "tailwind.config.ts"; text = "󱏿"; fg = "#209fb5"; }
              { name = "security.md"; text = "󰒃"; fg = "#bcc0cc"; }
              { name = "security"; text = "󰒃"; fg = "#bcc0cc"; }
              { name = ".eslintrc"; text = ""; fg = "#8839ef"; }
              { name = "gradle.properties"; text = ""; fg = "#1e66f5"; }
              { name = "code_of_conduct.md"; text = ""; fg = "#e64553"; }
              { name = "PrusaSlicerGcodeViewer.ini"; text = ""; fg = "#fe640b"; }
              { name = "PrusaSlicer.ini"; text = ""; fg = "#fe640b"; }
              { name = "procfile"; text = ""; fg = "#7c7f93"; }
              { name = "mpv.conf"; text = ""; fg = "#4c4f69"; }
            ];

            exts = [
              { name = "otf"; text = ""; fg = "#eff1f5"; }
              { name = "import"; text = ""; fg = "#eff1f5"; }
              { name = "krz"; text = ""; fg = "#ea76cb"; }
              { name = "adb"; text = ""; fg = "#dce0e8"; }
              { name = "ttf"; text = ""; fg = "#eff1f5"; }
              { name = "webpack"; text = "󰜫"; fg = "#209fb5"; }
              { name = "dart"; text = ""; fg = "#1e66f5"; }
              { name = "vsh"; text = ""; fg = "#7287fd"; }
              { name = "doc"; text = "󰈬"; fg = "#1e66f5"; }
              { name = "zsh"; text = ""; fg = "#40a02b"; }
              { name = "ex"; text = ""; fg = "#7c7f93"; }
              { name = "hx"; text = ""; fg = "#df8e1d"; }
              { name = "fodt"; text = ""; fg = "#04a5e5"; }
              { name = "mojo"; text = ""; fg = "#fe640b"; }
              { name = "templ"; text = ""; fg = "#df8e1d"; }
              { name = "nix"; text = ""; fg = "#04a5e5"; }
              { name = "cshtml"; text = "󱦗"; fg = "#8839ef"; }
              { name = "fish"; text = ""; fg = "#5c5f77"; }
              { name = "ply"; text = "󰆧"; fg = "#8c8fa1"; }
              { name = "sldprt"; text = "󰻫"; fg = "#40a02b"; }
              { name = "gemspec"; text = ""; fg = "#d20f39"; }
              { name = "mjs"; text = ""; fg = "#df8e1d"; }
              { name = "csh"; text = ""; fg = "#5c5f77"; }
              { name = "cmake"; text = ""; fg = "#dce0e8"; }
              { name = "fodp"; text = ""; fg = "#df8e1d"; }
              { name = "vi"; text = ""; fg = "#df8e1d"; }
              { name = "msf"; text = ""; fg = "#1e66f5"; }
              { name = "blp"; text = "󰺾"; fg = "#7287fd"; }
              { name = "less"; text = ""; fg = "#4c4f69"; }
              { name = "sh"; text = ""; fg = "#5c5f77"; }
              { name = "odg"; text = ""; fg = "#eff1f5"; }
              { name = "mint"; text = "󰌪"; fg = "#40a02b"; }
              { name = "dll"; text = ""; fg = "#4c4f69"; }
              { name = "odf"; text = ""; fg = "#ea76cb"; }
              { name = "sqlite3"; text = ""; fg = "#dce0e8"; }
              { name = "Dockerfile"; text = "󰡨"; fg = "#7287fd"; }
              { name = "ksh"; text = ""; fg = "#5c5f77"; }
              { name = "rmd"; text = ""; fg = "#209fb5"; }
              { name = "wv"; text = ""; fg = "#04a5e5"; }
              { name = "xml"; text = "󰗀"; fg = "#fe640b"; }
              { name = "markdown"; text = ""; fg = "#4c4f69"; }
              { name = "qml"; text = ""; fg = "#40a02b"; }
              { name = "3gp"; text = ""; fg = "#df8e1d"; }
              { name = "pxi"; text = ""; fg = "#04a5e5"; }
              { name = "flac"; text = ""; fg = "#1e66f5"; }
              { name = "gpr"; text = ""; fg = "#ea76cb"; }
              { name = "huff"; text = "󰡘"; fg = "#8839ef"; }
              { name = "json"; text = ""; fg = "#40a02b"; }
              { name = "gv"; text = "󱁉"; fg = "#1e66f5"; }
              { name = "bmp"; text = ""; fg = "#7c7f93"; }
              { name = "lock"; text = ""; fg = "#bcc0cc"; }
              { name = "sha384"; text = "󰕥"; fg = "#7c7f93"; }
              { name = "cobol"; text = "⚙"; fg = "#1e66f5"; }
              { name = "cob"; text = "⚙"; fg = "#1e66f5"; }
              { name = "java"; text = ""; fg = "#d20f39"; }
              { name = "cjs"; text = ""; fg = "#40a02b"; }
              { name = "qm"; text = ""; fg = "#209fb5"; }
              { name = "ebuild"; text = ""; fg = "#4c4f69"; }
              { name = "mustache"; text = ""; fg = "#fe640b"; }
              { name = "terminal"; text = ""; fg = "#40a02b"; }
              { name = "ejs"; text = ""; fg = "#40a02b"; }
              { name = "brep"; text = "󰻫"; fg = "#40a02b"; }
              { name = "rar"; text = ""; fg = "#df8e1d"; }
              { name = "gradle"; text = ""; fg = "#1e66f5"; }
              { name = "gnumakefile"; text = ""; fg = "#7c7f93"; }
              { name = "applescript"; text = ""; fg = "#7c7f93"; }
              { name = "elm"; text = ""; fg = "#209fb5"; }
              { name = "ebook"; text = ""; fg = "#df8e1d"; }
              { name = "kra"; text = ""; fg = "#ea76cb"; }
              { name = "tf"; text = ""; fg = "#8839ef"; }
              { name = "xls"; text = "󰈛"; fg = "#40a02b"; }
              { name = "fnl"; text = ""; fg = "#eff1f5"; }
              { name = "kdbx"; text = ""; fg = "#40a02b"; }
              { name = "kicad_pcb"; text = ""; fg = "#eff1f5"; }
              { name = "cfg"; text = ""; fg = "#7c7f93"; }
              { name = "ape"; text = ""; fg = "#04a5e5"; }
              { name = "org"; text = ""; fg = "#179299"; }
              { name = "yml"; text = ""; fg = "#7c7f93"; }
              { name = "swift"; text = ""; fg = "#fe640b"; }
              { name = "eln"; text = ""; fg = "#7c7f93"; }
              { name = "sol"; text = ""; fg = "#209fb5"; }
              { name = "awk"; text = ""; fg = "#5c5f77"; }
              { name = "7z"; text = ""; fg = "#df8e1d"; }
              { name = "apl"; text = "⍝"; fg = "#df8e1d"; }
              { name = "epp"; text = ""; fg = "#df8e1d"; }
              { name = "app"; text = ""; fg = "#d20f39"; }
              { name = "dot"; text = "󱁉"; fg = "#1e66f5"; }
              { name = "kpp"; text = ""; fg = "#ea76cb"; }
              { name = "eot"; text = ""; fg = "#eff1f5"; }
              { name = "hpp"; text = ""; fg = "#7c7f93"; }
              { name = "spec.tsx"; text = ""; fg = "#1e66f5"; }
              { name = "hurl"; text = ""; fg = "#e64553"; }
              { name = "cxxm"; text = ""; fg = "#209fb5"; }
              { name = "c"; text = ""; fg = "#7287fd"; }
              { name = "fcmacro"; text = ""; fg = "#d20f39"; }
              { name = "sass"; text = ""; fg = "#dd7878"; }
              { name = "yaml"; text = ""; fg = "#7c7f93"; }
              { name = "xz"; text = ""; fg = "#df8e1d"; }
              { name = "material"; text = "󰔉"; fg = "#ea76cb"; }
              { name = "json5"; text = ""; fg = "#40a02b"; }
              { name = "signature"; text = "λ"; fg = "#fe640b"; }
              { name = "3mf"; text = "󰆧"; fg = "#8c8fa1"; }
              { name = "jpg"; text = ""; fg = "#7c7f93"; }
              { name = "xpi"; text = ""; fg = "#fe640b"; }
            ];
          };
        };
      };
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}