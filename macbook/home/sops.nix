{
  config,
  lib,
  ...
}: let
  ageKeyDir = "${config.home.homeDirectory}/.config/sops/age";
in {
  # sops + age + YubiKey secret workflow — see manuals/sops-mnemonic.md.
  # The `mnemonic-show` helper lives in fish.nix (it's a fish function);
  # the CLI tools (sops/age/age-plugin-yubikey) are in modules/apps.nix.

  # Where sops looks for age identities. keys.txt holds the YubiKey
  # identity STUB (card metadata, regenerable with
  # `age-plugin-yubikey --identity`) — deliberately NOT managed by
  # home-manager: this repo is public and the stub leaks the card serial.
  home.sessionVariables.SOPS_AGE_KEY_FILE = "${ageKeyDir}/keys.txt";

  # Only guarantee the directory exists, so the one-time manual append
  # (`cat age-yubikey-identity-*.txt >> $SOPS_AGE_KEY_FILE`) never
  # trips over a missing path on a fresh machine.
  home.activation.sopsAgeKeyDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "${ageKeyDir}"
  '';

  # ~/secrets/.sops.yaml — encryption rules for personal sops files.
  # Only PUBLIC material lives here (recipients + path rules), so it is
  # safe in this public repo. The ciphertexts themselves (e.g.
  # mnemonic.yaml) deliberately stay OUT of git: publishing a wallet
  # mnemonic's ciphertext forever is a bet its crypto never breaks.
  # Workflow and rationale: manuals/sops-mnemonic.md.
  home.file."secrets/.sops.yaml".text = ''
    keys:
      # daily: age identity on the YubiKey PIV slot (card + PIN + touch)
      - &macbook-yk age1yubikey1qgme5xh9h60f08psmuxrr5wlj6uehwypyhq6sntwywsqehkv4m2gyk8twm9
      # disaster recovery: software age key; the secret half exists on paper only
      - &paper age15gty9fgkvwadz0rv48jhprn2nxskymfljjywkchte5zdnf3wz5ysrqlauk

    creation_rules:
      - path_regex: .*\.yaml$
        key_groups:
          # single key_group = any-of (either key decrypts alone).
          # Never split into two groups: that becomes an all-of
          # threshold — an inverted single point of failure.
          - age:
              - *macbook-yk
              - *paper
  '';
}
