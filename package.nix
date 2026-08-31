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
  pico_version ? "0.3.0d2",
  pico_hashes ? {
    amd64 = "sha256-deGRvkJJoItL7oLT0OAhJ67dMePZPQT+MLVTbY/PCEY=";
    raspi = "sha256-uoR4jwsEPXXPS+U6jfgPLBkvOoR+TRAjrL64ISTLrnU=";
  },
  dyn ? true,
  download_email ? "",
  download_token ? "",
  ...
}: let
  pname = "picotron";
  arch_string = {
    x86_64-linux = "amd64";
    aarch64-linux = "raspi";
  }.${stdenvNoCC.targetPlatform.system};
  dyn_suffix =
    if dyn && arch_string != "raspi"
    then "_dyn"
    else "";
in
  stdenvNoCC.mkDerivation {
    inherit pname;
    version = pico_version;
    nativeBuildInputs = [autoPatchelfHook makeShellWrapper unzip];
    src = fetchurl {
      hash = pico_hashes.${arch_string};
      url = "https://www.lexaloffle.com/dl/user/${download_email}/${download_token}/picotron_${pico_version}_${arch_string}.zip";
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
