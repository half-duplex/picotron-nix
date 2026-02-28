{
  autoPatchelfHook,
  fetchurl,
  lib,
  makeDesktopItem,
  makeShellWrapper,
  stdenvNoCC,
  curl,
  SDL2,
  unzip,
  dyn ? true,
  ...
}: let
  pname = "picotron";
  version = "0.2.2b";
  hash = "sha256-QLdgym7C36NHoZVx7AbMn4pKZ67xcYNStJVi5g8m4Js=";
  dyn_suffix =
    if dyn
    then "_dyn"
    else "";
in
  stdenvNoCC.mkDerivation {
    inherit pname version;
    nativeBuildInputs = [autoPatchelfHook makeShellWrapper unzip];
    src = fetchurl {
      inherit hash;
      url = "picotron_${version}_amd64.zip";
    };
    buildInputs = [SDL2];
    runtimeDependencies = [curl.out];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall

      mkdir -p "$out/"{bin,"opt/${pname}"}
      cp \
        picotron${dyn_suffix} \
        picotron.dat \
        picotron_manual.txt \
        license.txt \
        "$out/opt/${pname}/"
      install -m 644 -D lexaloffle-picotron.png \
        "$out/share/icons/hicolor/128x128/apps/${pname}.png"

      # The binary expects picotron.dat to be in the CWD
      makeShellWrapper \
        "$out/opt/${pname}/picotron${dyn_suffix}" \
        "$out/bin/${pname}" \
        --chdir "$out/opt/${pname}"

      install -m 644 -D -t "$out/share/applications" "$desktopItem/share/applications"/*

      runHook postInstall
    '';

    desktopItem = makeDesktopItem {
      desktopName = pname;
      name = "Picotron";
      comment = "Fantasy workstation creative environment";
      categories = ["Game" "Emulator"];
      exec = "picotron";
      icon = "picotron";
      keywords = ["p64"];
      startupWMClass = "picotron";
    };

    meta = with lib; {
      license = licenses.unfree;
    };
  }
