final: _:
let
  whispercpp =
    {
      pkgs,
      lib,
      stdenv,
      fetchFromGitHub,
    }:
    with pkgs;
    stdenv.mkDerivation rec {
      name = "whispercpp";
      version = "1.2.1";

      src = fetchFromGitHub {
        owner = "ggerganov";
        repo = name;
        rev = "v${version}";
        sha256 = "gcw+tcrwCt2CynNXQZxb+WxN/0chIQIJnwUAw9JGkYA=";
      };

      #src = ./.;

      buildInputs = [ pkgs.gnumake ];

      #   preConfigure = ''
      #     #cd src
      #     # disable default static linking
      #     #sed -i 's/ -static / /' makefile
      #   '';

      installPhase = ''
        runHook preInstall
        #install -Dt $out/bin whispercpp
        install -D main $out/bin/${name}
        runHook postInstall
      '';

      meta = with lib; {
        description = "High-performance inference of OpenAI's Whisper automatic speech recognition (ASR) model";
        license = licenses.mit;
        homepage = "https://github.com/ggerganov/whisper.cpp";
        maintainers = with maintainers; [ ripx80 ];
        platforms = platforms.all; # platforms.x86_64 ++ platforms.aarch64;
      };
    };
in
{
  whispercpp = final.callPackage whispercpp { };
}
