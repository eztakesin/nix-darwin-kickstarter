{
  pkgs,
  config,
  ...
}: let
  # Launchd wrapper: pull the RPC secret from the login Keychain at start
  # so it never touches this (public) repo or the world-readable store.
  # One-time setup on a new machine:
  #   security add-generic-password -s aria2-rpc -a (whoami) -w
  # If the item is missing the daemon still starts, just without a secret
  # (acceptable: RPC is loopback-only on a single-user machine).
  aria2Launcher = pkgs.writeShellScript "aria2-launchd" ''
    secret="$(/usr/bin/security find-generic-password -s aria2-rpc -w 2>/dev/null || true)"
    exec ${pkgs.aria2}/bin/aria2c \
      --conf-path="${config.xdg.configHome}/aria2/aria2.conf" \
      ''${secret:+--rpc-secret="$secret"}
  '';
in {
  # Migrated from dotfiles/aria2/aria2.conf (Starlink + VPN + public BT, no PT).
  # home-manager writes this to ~/.config/aria2/aria2.conf (XDG path, which
  # aria2 ≥1.36 reads natively). State (session/DHT/logs) stays in ~/.aria2/
  # — that directory must exist; aria2 errors if input-file's parent is gone.
  #
  # bt-tracker is intentionally NOT set here: the config file is a read-only
  # store symlink, so the old trackers-list-aria2.sh append/sed approach can't
  # work. The script now pushes the fresh list into the running daemon via
  # RPC (aria2.changeGlobalOption) instead — see dotfiles/aria2/.
  programs.aria2 = {
    enable = true;

    settings = {
      ##### Basic #####
      dir = "~/Downloads";

      input-file = "~/.aria2/aria2.session";
      save-session = "~/.aria2/aria2.session";
      save-session-interval = 60;

      continue = true;
      allow-overwrite = true;
      always-resume = true;
      auto-file-renaming = true;
      content-disposition-default-utf8 = true;

      ##### Logging #####
      log-level = "notice";
      log = "~/.aria2/aria2.log";
      quiet = true;

      ##### RPC #####
      enable-rpc = true;
      rpc-allow-origin-all = true;
      rpc-listen-all = false;
      rpc-listen-port = 6800;
      # rpc-secret deliberately NOT here (public repo + world-readable
      # store): the launchd wrapper above injects it from the Keychain
      # via --rpc-secret at startup.

      ##### HTTP/HTTPS/FTP #####
      max-concurrent-downloads = 5;
      max-connection-per-server = 16;
      min-split-size = "8M";
      split = 16;

      disk-cache = "64M";
      no-file-allocation-limit = "8M";

      ##### Network (Starlink/VPN) #####
      connect-timeout = 20;
      timeout = 60;
      retry-wait = 3;
      max-tries = 5;

      ##### BitTorrent / Magnet #####
      follow-torrent = true;
      bt-save-metadata = true;

      listen-port = "50101-50109";
      dht-listen-port = "50101-50109";

      enable-dht = true;
      enable-dht6 = true;
      enable-peer-exchange = true;
      bt-enable-lpd = true;

      dht-file-path = "~/.aria2/dht.dat";
      dht-file-path6 = "~/.aria2/dht6.dat";

      dht-entry-point = "dht.transmissionbt.com:6881";
      dht-entry-point6 = "dht.transmissionbt.com:6881";

      bt-tracker-connect-timeout = 15;
      bt-tracker-timeout = 15;
      bt-max-peers = 100;

      seed-time = 0;
      seed-ratio = 0.1;
    };
  };

  # Always-on daemon. Logs: ~/Library/Logs/aria2-launchd.log (launchd
  # stdout/stderr; aria2's own log stays in ~/.aria2/aria2.log).
  launchd.agents.aria2 = {
    enable = true;
    config = {
      ProgramArguments = ["${aria2Launcher}"];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/aria2-launchd.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/aria2-launchd.log";
    };
  };

  # AriaNg — static web UI for the aria2 RPC. `aria2-ui` opens it in the
  # default browser (Safari); it talks to localhost:6800 directly from the
  # page (rpc-allow-origin-all covers the file:// origin). Enter the
  # Keychain secret once in AriaNg settings (stored in browser storage).
  home.packages = [pkgs.ariang];
  programs.fish.functions.aria2-ui = {
    description = "open the AriaNg web UI for the local aria2 daemon";
    body = ''
      open /etc/profiles/per-user/(whoami)/share/ariang/index.html
    '';
  };
}
