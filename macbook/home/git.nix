{
  lib,
  pkgs,
  username,
  useremail,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;

    ignores = [ "*~" "*.swp" "\\#*\\#" ".\\#*"  ".vim/coc-settings.json" ".vscode" ".envrc"]; # vim swap file & emacs

    includes = [
      {
        # use diffrent email & name for work
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];

    extraConfig = {
      # User & signing.
      # TODO replace with your own name & email
      user.name = "eztakesin";
      user.email = "amatoki@shiohara.me";
      # user.signingKey = my.gpg.fingerprint;
      tag.gpgSign = true;

      # Pull.
      pull.ff = "only";

      # Diff & merge.
      diff.external = "${pkgs.difftastic}/bin/difft";
      diff.tool = "nvimdiff";
      difftool.prompt = false;
      merge.tool = "nvimdiff";
      merge.conflictstyle = "diff3";
      mergetool.prompt = false;
      rerere.enabled = true;

      # Pager.
      core.pager = "less";
      pager.branch = "less --quit-if-one-screen";
      pager.stash = "less --quit-if-one-screen";

      # Display.
      # Always show branches and tags for `git log` in `vim-fugitive`.
      # See: https://github.com/tpope/vim-fugitive/issues/1965
      log.decorate = true;
      # Show detailed diff by default for `git stash show`.
      stash.showPatch = true;

      # Misc.
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      advice.detachedHead = false;
    };

    # signing = {
    #   key = "xxx";
    #   signByDefault = true;
    # };

    # delta = {
    #   enable = true;
    #   options = {
    #     features = "side-by-side";
    #   };
    # };

    aliases = {
      # common aliases
      br = "branch";
      cmt = "commit -m";
      ca = "commit --amend -m";
      co = "checkout";
      cp = "cherry-pick";
      d = "diff";
      dc = "diff --cached";
      dt = "difftool";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      mt = "mergetool";
      st = "status";
      sub = "submodule";

      # aliases for submodule
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
    };
  };

  # programs.gh.enable = true;
}