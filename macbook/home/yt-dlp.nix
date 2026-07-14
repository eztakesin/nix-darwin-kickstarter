{...}: {
  # Feature-rich command-line audio/video downloader.
  # Config is written to ~/.config/yt-dlp/config; long-form option names
  # only (short forms would go into extraConfig).
  programs.yt-dlp = {
    enable = true;

    settings = {
      # Files land next to aria2's downloads.
      output = "~/Downloads/%(title)s [%(id)s].%(ext)s";

      # Embed everything into the media file instead of sidecar files.
      embed-thumbnail = true;
      embed-metadata = true;
      embed-subs = true;
      sub-langs = "ja,zh-Hans,en";

      # Hand the actual transfer to aria2c (same tuning as the aria2
      # config: resume, 8 connections, 1M chunks).
      downloader = "aria2c";
      downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
    };
  };
}
