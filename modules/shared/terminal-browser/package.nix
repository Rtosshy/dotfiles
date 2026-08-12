{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "terminal-browser";
  version = "0.3.3";

  src = fetchurl {
    url = "https://terminal-browser.sh/install/dl/stable/v0.3.3/terminal-browser-darwin-arm64.tar.gz";
    sha256 = "02gx8zw3qkbqvk6dghjksmp737cn4m49iy920fpcmcd24wc26140";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R . "$out"
    chmod +x "$out/bin/terminal-browser"

    runHook postInstall
  '';

  # Darwin fixups and stripping invalidate the bundled Electron app's signature.
  dontFixup = true;
  dontStrip = true;

  meta = {
    description = "Electron-based browser that runs in the terminal";
    homepage = "https://terminal-browser.com/";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "terminal-browser";
  };
}
