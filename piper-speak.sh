#/usr/bin/env bash

echo "$@" | piper --model /home/johannes/piper-voices/en/en_US/libritts_r/medium/en_US-libritts_r-medium.onnx -s 605 --output-raw --length-scale 0.80 --sentence-silence 0.0 | ffmpeg -f s16le -i pipe:0 -filter_complex "[0:a]asetrate=44100*1,aresample=44100,atempo=1.6" -f s16le pipe:1 | aplay -r 22050 -f S16_LE -t raw
