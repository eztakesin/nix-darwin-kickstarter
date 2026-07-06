{
  lib,
  stdenvNoCC,
  fetchzip,
}: let
  # Language-specific single-file OTFs from the noto-cjk releases, instead
  # of nixpkgs' noto-fonts-cjk-{sans,serif}(-static): every nixpkgs variant
  # ships CFF font *collections* (.ttc / OTC), which MS Office's font engine
  # cannot parse — documents referencing "Noto Sans CJK JP/SC" render
  # garbled in Excel/Word and trigger the "we are unable to load all your
  # fonts" warning. Single-file CFF OTFs are fine, and these carry exactly
  # those family names. JP + SC only; other regions are covered by fallback
  # (sarasa-gothic ships all regions as TrueType).
  sansVersion = "2.004";
  serifVersion = "2.003";

  zips = [
    (fetchzip {
      url = "https://github.com/notofonts/noto-cjk/releases/download/Sans${sansVersion}/06_NotoSansCJKjp.zip";
      stripRoot = false;
      sha256 = "06iirf7l2ffsr5jk1bahfgrb6yswnsrz77ni5v7cfird59aig022";
    })
    (fetchzip {
      url = "https://github.com/notofonts/noto-cjk/releases/download/Sans${sansVersion}/08_NotoSansCJKsc.zip";
      stripRoot = false;
      sha256 = "1nd671hy4g3dy153dmg8xqq4f0brw6d21xyrzylmi0jkls92m5f4";
    })
    (fetchzip {
      url = "https://github.com/notofonts/noto-cjk/releases/download/Serif${serifVersion}/07_NotoSerifCJKjp.zip";
      stripRoot = false;
      sha256 = "1wxxfxi5xl124m3fg0c7mar3r9kms5d9vpwzn7zzdmlqi81v6pvn";
    })
    (fetchzip {
      url = "https://github.com/notofonts/noto-cjk/releases/download/Serif${serifVersion}/09_NotoSerifCJKsc.zip";
      stripRoot = false;
      sha256 = "19ikmapgd613fydcfv9gji9ypsgcgi4v4pkc1n8l960apflil3rf";
    })
  ];
in
  stdenvNoCC.mkDerivation {
    pname = "noto-cjk-otf";
    version = sansVersion;

    srcs = zips;
    sourceRoot = ".";
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -d $out/share/fonts/opentype/noto-cjk-otf
      for src in ${lib.concatStringsSep " " (map toString zips)}; do
        find "$src" -name '*.otf' -exec install -m444 {} $out/share/fonts/opentype/noto-cjk-otf/ \;
      done
      runHook postInstall
    '';

    meta = {
      description = "Noto CJK JP/SC as language-specific single OTFs (MS Office compatible)";
      homepage = "https://github.com/notofonts/noto-cjk";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  }
