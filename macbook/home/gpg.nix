{
  config,
  pkgs,
  lib,
  my,
  ...
}: {
  programs.gpg = {
    enable = true;

    # ~/.gnupg/gpg.conf — hardened defaults from drduh/YubiKey-Guide,
    # with deviations annotated below.
    settings = {
      # Identity
      default-key = my.gpg.fingerprint;

      # Algorithm preferences
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";

      # Output / display
      charset = "utf-8";
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      armor = true;

      # Security
      require-cross-certification = true;
      no-symkey-cache = true;
      use-agent = true;
      # require-secmem — drduh enables this. Omitted: gpg on macOS often
      # cannot mlock and would then refuse to run.
      # throw-keyids — drduh enables this for recipient anonymity. Omitted
      # because it breaks Mailvelope and forces every key to be tried for
      # every decrypt. Re-enable if your threat model needs it.

      # Keyserver
      keyserver = "hkps://keys.openpgp.org";
    };

    # ~/.gnupg/scdaemon.conf — talks to the smartcard.
    scdaemonSettings = {
      # Share the reader with macOS's PCSC stack instead of grabbing it
      # exclusively. Lets `sc-auth`, Safari client certs, etc. coexist.
      pcsc-shared = true;

      # Skip scdaemon's internal CCID driver and use the macOS native PCSC
      # framework instead. Recommended on macOS — without this, GnuPG often
      # keeps prompting "insert your YubiKey" even when it's already plugged
      # in, because the internal CCID driver loses the device after macOS
      # has already claimed it.
      disable-ccid = true;
    };
  };

  # ~/.gnupg/gpg-agent.conf — written manually because services.gpg-agent
  # in home-manager is Linux/launchd-flavored; writing the file is portable.
  #
  # After `darwin-rebuild switch`, reload the agent with:
  #   gpgconf --kill gpg-agent
  home.file.".gnupg/gpg-agent.conf".text = ''
    # Managed by home-manager (home/gpg.nix)

    # PIN cache lifetimes (seconds). 10 min idle, 30 min max.
    default-cache-ttl 600
    max-cache-ttl 1800
    default-cache-ttl-ssh 600
    max-cache-ttl-ssh 1800

    # Native macOS pinentry GUI. Pulled from the Nix store.
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac

    # Expose the YubiKey authentication subkey as an SSH key.
    # `ssh-add -L` should list it once the card is plugged in.
    enable-ssh-support
  '';

  home.packages = [ pkgs.pinentry_mac ];

  # Wire up the SSH agent socket so ssh/git automatically use gpg-agent.
  # Also export GPG_TTY so pinentry knows where to draw the TTY prompt
  # (useful when pinentry-mac is unavailable, e.g. over plain SSH).
  #
  # `gpgconf --launch` eagerly starts gpg-agent so the SSH socket exists
  # immediately (otherwise it's lazy-spawned on first connection).
  # `updatestartuptty` tells the running agent that the current tty is
  # where pinentry-curses should render if pinentry-mac is unavailable
  # (e.g. inside tmux or over SSH).
  programs.fish.interactiveShellInit = lib.mkAfter ''
    set -gx GPG_TTY (tty)
    set -gx SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
    ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
    ${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye >/dev/null
  '';

  # Quick file encrypt/decrypt helpers, fish port of drduh's bash functions.
  # The recipient is hardcoded to your own fingerprint at build time, so the
  # functions Just Work without needing $KEYID in the environment.
  programs.fish.functions = {
    secret = {
      description = "Encrypt a file for yourself with gpg, write <file>.<ts>.enc";
      body = ''
        if test (count $argv) -lt 1
            echo "usage: secret <file>" >&2
            return 1
        end
        set -l in $argv[1]
        if not test -f "$in"
            echo "secret: '$in' is not a regular file" >&2
            return 1
        end
        set -l out "$in".(date +%s).enc
        gpg --encrypt --armor --output $out -r ${my.gpg.fingerprint} -- $in
        and echo "$in -> $out"
      '';
    };

    reveal = {
      description = "Decrypt a <file>.<ts>.enc produced by `secret`";
      body = ''
        if test (count $argv) -lt 1
            echo "usage: reveal <file.<ts>.enc>" >&2
            return 1
        end
        set -l in $argv[1]
        set -l out (string replace -r '\.\d+\.enc$' "" -- $in)
        if test "$in" = "$out"
            echo "reveal: '$in' does not look like a secret-encoded file" >&2
            return 1
        end
        gpg --decrypt --output $out -- $in
        and echo "$in -> $out"
      '';
    };
  };
}
