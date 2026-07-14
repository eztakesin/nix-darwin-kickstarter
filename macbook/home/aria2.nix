{...}: {
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
      # NOTE: lives in the world-readable nix store. Acceptable while RPC is
      # loopback-only (rpc-listen-all = false) on a single-user machine; if
      # that ever changes, move the secret out (sops-nix) before exposing.
      # Regenerate on a new machine: pwgen -s 32 1
      rpc-secret = "CHANGE_ME_ON_NEW_MACHINE";

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
}
