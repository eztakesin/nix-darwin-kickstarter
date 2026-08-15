{
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;

    # ── Vi mode & cursor ──
    interactiveShellInit = ''
      fish_vi_key_bindings

      # Cursor shapes per vi mode
      set fish_cursor_default block blink
      set fish_cursor_insert line blink
      set fish_cursor_replace_one underscore blink

      # Fish color scheme
      set fish_color_normal normal
      set fish_color_command blue
      set fish_color_quote yellow
      set fish_color_redirection cyan --bold
      set fish_color_end green
      set fish_color_error brred
      set fish_color_param cyan
      set fish_color_comment red
      set fish_color_match --background=brblue
      set fish_color_selection white --bold --background=brblack
      set fish_color_search_match bryellow --background=brblack
      set fish_color_history_current --bold
      set fish_color_operator brcyan
      set fish_color_escape brcyan
      set fish_color_cwd green
      set fish_color_cwd_root red
      set fish_color_valid_path --underline
      set fish_color_autosuggestion white
      set fish_color_user brgreen
      set fish_color_host normal
      set fish_color_cancel --reverse
      set fish_pager_color_prefix normal --bold --underline
      set fish_pager_color_progress brwhite --background=cyan
      set fish_pager_color_completion normal
      set fish_pager_color_description B3A06D --italics
      set fish_pager_color_selected_background --reverse

      # ── PATH ordering (nix > brew > user tools > system) ──
      # 1. Brew (lowest priority of the three)
      eval (/opt/homebrew/bin/brew shellenv)
      # 2. Nix paths prepended AFTER brew, so they take priority.
      # -m/--move is essential: nix-darwin's base config already put these
      # paths in $PATH, and without --move fish_add_path SKIPS existing
      # entries instead of moving them forward — leaving brew's python3
      # etc. shadowing the nix ones.
      fish_add_path -gmP /etc/profiles/per-user/(whoami)/bin
      fish_add_path -gmP /run/current-system/sw/bin
      # 3. User tools (highest priority)
      fish_add_path -g $HOME/.cargo/bin
      fish_add_path -g $HOME/.local/bin
      # Trading workspace binaries (hlguard / bot / panel / feed / news).
      # Deliberately NOT `cargo install`ed: these are rebuilt constantly and
      # a stale installed copy silently doing the old thing is exactly the
      # failure mode this project cannot afford (a `hlguard` that predates a
      # stop-loss fix would report coverage that no longer matches reality).
      # Pointing at the build output means "what you run is what you built".
      fish_add_path -g $HOME/Workspace/trading-workspace/target/release

      # ── kitty shell integration ──
      function mark_prompt_start --on-event fish_prompt
          echo -en "\e]133;A\e\\"
      end

      # ── Prompt ──
      zoxide init fish | source
      starship init fish | source
    '';

    # ── Shell aliases (Rust alternatives) ──
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -lh --icons --git";
      la = "eza -lah --icons --git";
      lt = "eza --tree --icons --level=2";
      jq = "jaq";
      fzf = "sk";
      du = "dust";
      curl = "xh";
      http = "xh";
      https = "xhs";
      ping = "gping";
      nmap = "rustscan";
      mtr = "trip";
      iftop = "sudo bandwhich";
      tar = "ouch";
      untar = "ouch decompress";
    };

    # ── Functions ──
    functions = {
      greeting = {
        body = ''
          set_color -o EEA9A9; date +%T; set_color normal
        '';
      };
      nvim = {
        body = ''
          env NVIM_APPNAME="nvim-Lazyman" command nvim $argv
        '';
        wraps = "nvim";
      };
      # sops+Keychain secret pair — see manuals/sops-mnemonic.md.
      # secret-save NAME: prompt (hidden) → sops-encrypt (rules from
      # ~/secrets/.sops.yaml) → write ~/secrets/NAME.yaml AND a Keychain
      # item "NAME-sops". secret-show NAME: Keychain → hex-decode
      # (`security -w` hex-encodes multiline payloads) → sops decrypt
      # (YubiKey PIN + touch; disaster path: paper key via SOPS_AGE_KEY).
      # secret-group NAME MEMBER...: bundle several existing secrets into one
      # multi-line secret, so loading the whole set costs ONE YubiKey touch
      # instead of N. Payload format is "MEMBER:VALUE" per line — the same
      # shape the trading panel parses from stdin.
      #
      # Bundle AGENT keys, not master keys. Agent keys are used on every
      # panel launch and can only trade (never withdraw), so one touch for
      # the set is a good trade. Master keys are used exactly once each (to
      # approve an agent) and can move funds — bundling those would buy a
      # convenience you never need at the price of unlocking every wallet's
      # withdrawal rights in a single touch.
      secret-group = {
        description = "bundle several secrets into one (single YubiKey touch to load all)";
        body = ''
          set -l name $argv[1]
          set -l members $argv[2..-1]
          if test -z "$name" -o (count $members) -eq 0
              echo "usage: secret-group NAME MEMBER..." >&2
              echo "  e.g. secret-group hl-agents hl-agent-rabby6 hl-agent-rabby7" >&2
              return 1
          end
          # Collect first: if any member fails to decrypt, abort before
          # touching the destination. A half-written group is worse than none.
          set -l lines
          for m in $members
              set -l v (secret-show $m)
              or begin
                  echo "cannot read secret '$m', aborting (nothing was written)" >&2
                  return 1
              end
              if test -z "$v"
                  echo "secret '$m' is empty, aborting" >&2
                  return 1
              end
              # Strip a leading "hl-agent-" so the label matches the account
              # name the panel shows (hl-agent-rabby6 -> rabby6).
              set -l label (string replace -r '^hl-agent-' "" $m)
              set -a lines "$label:$v"
          end
          # YAML block scalar: one key whose value is the multi-line payload.
          # sops encrypts it as a single ciphertext, so secret-show returns
          # it verbatim — same shape as any other secret.
          # Encrypt to a temp file first, then mv on success: a bare
          # `> ~/secrets/$name.yaml` truncates the target BEFORE sops runs,
          # so a failing sops would wipe an existing group (same guard as
          # secret-save).
          set -l tmp (mktemp)
          begin
              echo "$name: |"
              for l in $lines
                  echo "  $l"
              end
          end | sops --config ~/secrets/.sops.yaml -e --filename-override ~/secrets/$name.yaml /dev/stdin > $tmp
          or begin
              set -e lines
              rm -f $tmp
              echo "sops failed; ~/secrets/$name.yaml untouched" >&2
              return 1
          end
          set -e lines
          mv $tmp ~/secrets/$name.yaml
          security add-generic-password -U -s $name-sops -a (whoami) -w (cat ~/secrets/$name.yaml | string collect)
          echo "grouped "(count $members)" secrets: ~/secrets/$name.yaml + Keychain item $name-sops"
          echo "load them all with one touch:  secret-show $name | panel"
        '';
      };
      secret-save = {
        description = "encrypt a secret with sops and store it in Apple Keychain";
        body = ''
          set -l name $argv[1]
          if test -z "$name"
              echo "usage: secret-save NAME" >&2
              return 1
          end
          read -s -P "$name> " value
          or return 1
          if test -z "$value"
              echo "empty input, aborting" >&2
              return 1
          end
          # -c/--config pins the creation_rules source to ~/secrets/.sops.yaml
          # so encryption works from ANY cwd. --filename-override only feeds
          # the path_regex; it does NOT locate .sops.yaml (sops otherwise walks
          # up from cwd and, outside ~/secrets, finds no rules and drops the key).
          # Encrypt to a temp file first, then mv on success: a bare
          # `> ~/secrets/$name.yaml` truncates the target BEFORE sops runs, so a
          # failing sops would wipe an existing secret.
          set -l tmp (mktemp)
          echo "$name: $value" | sops --config ~/secrets/.sops.yaml -e --filename-override ~/secrets/$name.yaml /dev/stdin > $tmp
          or begin
              set -e value
              rm -f $tmp
              return 1
          end
          set -e value
          mv $tmp ~/secrets/$name.yaml
          security add-generic-password -U -s $name-sops -a (whoami) -w (cat ~/secrets/$name.yaml | string collect)
          echo "saved: ~/secrets/$name.yaml + Keychain item $name-sops"
        '';
      };
      secret-show = {
        description = "decrypt a sops secret from Apple Keychain via YubiKey";
        body = ''
          set -l name $argv[1]
          if test -z "$name"
              echo "usage: secret-show NAME" >&2
              return 1
          end
          security find-generic-password -s $name-sops -w | xxd -r -p | sops -d --input-type yaml --output-type yaml --extract "[\"$name\"]" /dev/stdin
        '';
      };
      mnemonic-show = {
        description = "decrypt mnemonic from Apple Keychain via YubiKey (sops+age)";
        body = ''
          secret-show mnemonic
        '';
      };
    };

    # ── Plugins ──
    plugins = [];
  };

  # ── Environment variables ──
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    LESS = "--RAW-CONTROL-CHARS --mouse --wheel-lines=5 --LONG-PROMPT";
    LESSOPEN = "";
    # SOPS_AGE_KEY_FILE moved to home/sops.nix
  };
}
