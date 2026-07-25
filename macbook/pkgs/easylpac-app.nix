# Minimal macOS .app bundle for easylpac.
#
# UPSTREAMED as NixOS/nixpkgs#545100 (desktopToDarwinBundle in the
# easylpac derivation itself) — delete this wrapper once that PR is
# merged AND the flake's nixpkgs (or the stable pin providing easylpac)
# contains it; the package will then ship its own .app.
#
# The nixpkgs package is a Linux-first port that ships only bin/ (no
# Applications/*.app), so it never shows up in Spotlight/Launchpad.
# This wrapper provides ONLY the bundle; the CLI still comes from the
# easylpac package itself (both live in home.packages side by side).
{
  lib,
  stdenvNoCC,
  fetchurl,
  writeShellScript,
  writeText,
  easylpac,
}: let
  # Official icon from the upstream repo. Tag-pinned so the URL stays
  # stable; the icon practically never changes — bump opportunistically
  # when the app version moves.
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/creamlike1024/EasyLPAC/0.8.0.3/assets/icon.icns";
    hash = "sha256-PdW6tXm/hn7J0L89zMxKeqvuUxey2+9+dYKAxbDggOw=";
  };

  launcher = writeShellScript "EasyLPAC-launcher" ''
    exec ${easylpac}/bin/easylpac "$@"
  '';

  infoPlist = writeText "EasyLPAC-Info.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleName</key><string>EasyLPAC</string>
      <key>CFBundleDisplayName</key><string>EasyLPAC</string>
      <key>CFBundleExecutable</key><string>EasyLPAC</string>
      <key>CFBundleIconFile</key><string>EasyLPAC</string>
      <key>CFBundleIdentifier</key><string>com.github.creamlike1024.EasyLPAC</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>${easylpac.version}</string>
      <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
    </dict>
    </plist>
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "easylpac-app";
    inherit (easylpac) version;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      contents="$out/Applications/EasyLPAC.app/Contents"
      mkdir -p "$contents/MacOS" "$contents/Resources"
      cp ${infoPlist} "$contents/Info.plist"
      cp ${launcher} "$contents/MacOS/EasyLPAC"
      cp ${icon} "$contents/Resources/EasyLPAC.icns"

      runHook postInstall
    '';

    meta = {
      description = "macOS app-bundle launcher for easylpac";
      inherit (easylpac.meta) homepage license;
      platforms = lib.platforms.darwin;
    };
  }
