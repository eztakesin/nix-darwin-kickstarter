{
  # GPG identities. Each entry corresponds to one YubiKey.
  # Verify with: gpg --card-status (while that YubiKey is plugged in)
  gpg = {
    personal = {
      fingerprint = "D16DB211ADB752E5EE2B083EA66908491A30509A";
      name = "eztakesin";
      email = "qwquq@proton.me";
    };

    # Second YubiKey, on-card generated for work identity.
    # TODO: fill in after running `gpg --card-edit` → admin → generate
    # on the work YubiKey, then `gpg -K` to read off the new fingerprint.
    work = {
      fingerprint = "0000000000000000000000000000000000000000";
      name = "TODO-work-name";
      email = "TODO@work.example";
    };
  };
}
