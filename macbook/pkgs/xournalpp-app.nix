# Minimal macOS .app bundle for Xournal++.
#
# Same story as easylpac-app.nix: the nixpkgs darwin build installs
# only bin/ + share/, so Spotlight/Launchpad never see it. The wrapper
# provides ONLY the bundle; the CLI stays with the xournalpp package.
{
  lib,
  stdenvNoCC,
  fetchurl,
  writeShellScript,
  writeText,
  xournalpp,
}: let
  # Official icon from upstream's own macOS packaging (mac-setup/).
  # Tag-pinned; survives the package moving from the stable pin (1.3.4)
  # to unstable — the icon doesn't change between patch releases.
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/xournalpp/xournalpp/v1.3.4/mac-setup/icon/xournalpp.icns";
    hash = "sha256-7haGs540ZC7TfvX+2mNdVGZ392kLFpFdJmE0Wzyw408=";
  };

  launcher = writeShellScript "xournalpp-launcher" ''
    exec ${xournalpp}/bin/xournalpp "$@"
  '';

  infoPlist = writeText "xournalpp-Info.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key><string>Xournal++</string>
      <key>CFBundleDisplayName</key><string>Xournal++</string>
      <key>CFBundleExecutable</key><string>xournalpp</string>
      <key>CFBundleIconFile</key><string>xournalpp</string>
      <key>CFBundleIdentifier</key><string>com.github.xournalpp.xournalpp</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>${xournalpp.version}</string>
      <key>LSApplicationCategoryType</key><string>public.app-category.productivity</string>
    </dict>
    </plist>
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "xournalpp-app";
    inherit (xournalpp) version;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      contents="$out/Applications/Xournal++.app/Contents"
      mkdir -p "$contents/MacOS" "$contents/Resources"
      cp ${infoPlist} "$contents/Info.plist"
      cp ${launcher} "$contents/MacOS/xournalpp"
      cp ${icon} "$contents/Resources/xournalpp.icns"

      runHook postInstall
    '';

    meta = {
      description = "macOS app-bundle launcher for Xournal++";
      inherit (xournalpp.meta) homepage license;
      platforms = lib.platforms.darwin;
    };
  }
