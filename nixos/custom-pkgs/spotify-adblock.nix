# kanged from "https://github.com/NL-TCH/nur-packages/blob/master/pkgs/spotify-adblock/default.nix"
{
  spotify,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  xorg,
  zip,
  unzip,
}: let
  spotify-adblock = rustPlatform.buildRustPackage {
    pname = "spotify-adblock";
    version = "1.0.3";
    src = fetchFromGitHub {
      owner = "abba23";
      repo = "spotify-adblock";
      rev = "5a3281dee9f889afdeea7263558e7a715dcf5aab";
      hash = "sha256-5tZ+Y7dhzb6wmyQ+5FIJDHH0KqkXbiB259Yo7ATGjSU=";
    };
    cargoSha256 = "sha256-q6Z7lfVNs2MEhq8lOMqFBNDRCLmvH0lxoTJX9L/wbuU=";

    patchPhase = ''
      substituteInPlace src/lib.rs \
        --replace 'config.toml' $out/etc/spotify-adblock/config.toml
    '';

    buildPhase = ''
      make
     '';

    installPhase = ''
      mkdir -p $out/etc/spotify-adblock
      install -D --mode=644 config.toml $out/etc/spotify-adblock
      mkdir -p $out/lib
      install -D --mode=644 --strip target/release/libspotifyadblock.so $out/lib
      
    '';

  };
in
  spotify.overrideAttrs (
    old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ zip unzip ];
      postInstall =
        (old.postInstall or "")
        + ''
          ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir
          sed -i "s:^Name=Spotify.*:Name=Spotify-adblock:" "$out/share/spotify/spotify.desktop"
          wrapProgram $out/bin/spotify \
            --set LD_PRELOAD "${spotify-adblock}/lib/libspotifyadblock.so"

          # Hide placeholder for advert banner
          ${unzip}/bin/unzip -p $out/share/spotify/Apps/xpui.spa xpui.js | sed 's/adsEnabled:\!0/adsEnabled:false/' > $out/share/spotify/Apps/xpui.js
          ${zip}/bin/zip --junk-paths --update $out/share/spotify/Apps/xpui.spa $out/share/spotify/Apps/xpui.js
          rm $out/share/spotify/Apps/xpui.js
        '';
    }
  )
