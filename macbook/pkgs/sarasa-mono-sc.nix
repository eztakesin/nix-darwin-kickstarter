{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
}:
# Only the Sarasa Mono SC family (the one actually referenced, by
# dotfiles/firefox/user-overrides.js) instead of nixpkgs' sarasa-gothic:
# the full release ships style-based TTCs with every family × region
# variant — 480 font faces, the single biggest contributor to MS Office's
# "we are unable to load all your fonts" font-count limit.
stdenvNoCC.mkDerivation rec {
  pname = "sarasa-mono-sc";
  version = "1.0.39";

  src = fetchurl {
    url = "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${version}/SarasaMonoSC-TTF-${version}.7z";
    sha256 = "1jmb7bs0sbg4wx8z6593r1dbb23wrdg05y6g45wqa730z2vscj35";
  };

  nativeBuildInputs = [p7zip];

  unpackPhase = ''
    runHook preUnpack
    7z x ${src} -ofonts
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -d $out/share/fonts/truetype/sarasa-mono-sc
    find fonts -name '*.ttf' -exec install -m444 {} $out/share/fonts/truetype/sarasa-mono-sc/ \;
    runHook postInstall
  '';

  meta = {
    description = "Sarasa Mono SC only, from the per-family upstream release";
    homepage = "https://github.com/be5invis/Sarasa-Gothic";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
