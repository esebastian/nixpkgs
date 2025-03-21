{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  boost,
  zlib,
  openssl,
  upnpSupport ? true,
  miniupnpc,
  aesniSupport ? stdenv.hostPlatform.aesSupport,
}:

stdenv.mkDerivation rec {
  pname = "i2pd";
  version = "2.56.0";

  src = fetchFromGitHub {
    owner = "PurpleI2P";
    repo = "i2pd";
    tag = version;
    hash = "sha256-URFLVMd1j/br+/isQytVjSVosMHn1SEwqg2VNxStD0A=";
  };

  postPatch = lib.optionalString (!stdenv.hostPlatform.isx86) ''
    substituteInPlace Makefile.osx \
      --replace-fail "-msse" ""
  '';

  buildInputs = [
    boost
    zlib
    openssl
  ] ++ lib.optional upnpSupport miniupnpc;

  nativeBuildInputs = [
    installShellFiles
  ];

  makeFlags =
    let
      ynf = a: b: a + "=" + (if b then "yes" else "no");
    in
    [
      (ynf "USE_AESNI" aesniSupport)
      (ynf "USE_UPNP" upnpSupport)
    ];

  enableParallelBuilding = true;

  installPhase = ''
    install -D i2pd $out/bin/i2pd
    install --mode=444 -D 'contrib/i2pd.service' "$out/etc/systemd/system/i2pd.service"
    installManPage 'debian/i2pd.1'
  '';

  meta = with lib; {
    homepage = "https://i2pd.website";
    description = "Minimal I2P router written in C++";
    license = licenses.bsd3;
    maintainers = with maintainers; [ edwtjo ];
    platforms = platforms.unix;
    mainProgram = "i2pd";
  };
}
