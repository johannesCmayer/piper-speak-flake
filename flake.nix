{
  description = "A Nix-flake-based Shell development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ alsa-utils piper-tts ffmpeg bash ];
        };
      });
      packages = forEachSupportedSystem ({ pkgs }: rec {
        # /nix/store/2jks41a1sx25hl03z5zx4qg8al80i0yx-en_US-libritts-high.onnx?download=true
        piperModel = pkgs.fetchurl {
          url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/libritts/high/en_US-libritts-high.onnx?download=true";
          sha256 = "sha256-kSelWeEWA/ELNm0aIKx0JoJggdvFId5MJCDFdyjXPw8=";
        };
        piperModelJson = pkgs.fetchurl {
          url = "https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/en/en_US/libritts/high/en_US-libritts-high.onnx.json?download=true.json";
          sha256 = "sha256-Lv3G1/lUWIuBgBMsvZuAAZM/3QCTLJK8kv0NICip6z0=";
        };
        lengthScale = 0.8;
        atempo = 1.6;
        pitch = 1.0;
        default = pkgs.runCommand "piper-speak" {} ''
          mkdir -p $out/bin

          echo "#!${pkgs.bash}/bin/bash" >> $out/bin/piper-speak
          echo "cat - | ${pkgs.piper-tts}/bin/piper --model \"${piperModel}\" -c \"${piperModelJson}\" -s 605 --output-raw --length-scale ${pkgs.lib.strings.floatToString lengthScale} --sentence-silence 0.0 | ${pkgs.ffmpeg}/bin/ffmpeg -f s16le -i pipe:0 -filter_complex \"[0:a]asetrate=44100*${pkgs.lib.strings.floatToString pitch},aresample=44100,atempo=${pkgs.lib.strings.floatToString atempo}\" -f s16le pipe:1 | ${pkgs.alsa-utils}/bin/aplay -r 22050 -f S16_LE -t raw" >> $out/bin/piper-speak

          chmod +x $out/bin/piper-speak
        '';
        });
    };
}
  
    
