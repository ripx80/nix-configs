# whisper.cpp

[offical project repo](https://github.com/ggerganov/whisper.cpp)

how to use whisper.cpp with this overlay.

add whispercpp to your systemPackages:

```nix
environment.systemPackages = with pkgs; [
    whispercpp
]
```

then download a model for your prefered language.
in this example we will use the base en language model:

```sh
bash ./models/download-ggml-model.sh base.en
```

when you using the normal openai-whisper it will save the model to ~/.cache/whisper/model

## different models

if you want to use a different model you can download the model directly from huggingface or use the /models/convert-pt-to-ggml.py script.
here it will be download the large model in ggml format.

```sh
curl -L --output ggml-large.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large.bin
```

## convert models to ggml

```sh
python convert-pt-to-ggml.py ~/.cache/whisper/medium.pt ~/path/to/repo/whisper/ ./models/whisper-medium
python convert-pt-to-ggml.py ~/.cache/whisper/large.pt ~/proj/s2t/whisper-repo/ ./de/
```

## how to use

```sh
whispercpp -m models/ggml-large.bin -f samples/13.03-t1.wav -l de
time whispercpp -m models/ggml-large.bin -f samples/13.03-t1.wav -l de -t 8 -bs 1 -bo 1
# with offset in ms, equal time but better results
time whispercpp -m models/ggml-large.bin -f samples/13.03-t1.wav -l de -t 8 -ot 1020000 -pp -otxt -of out

# wav must be 16kHz so convert with ffmpeg
ffmpeg -i input.mp3 -ar 16000 -ac 1 -c:a pcm_s16le output.wav

# remove silence form audio
ffmpeg -i input.mp3 -af silenceremove=1:0:-50dB output.mp3

# split in parts
ffmpeg -ss 60 -i input-audio.aac -t 15 -c copy output.aac

# remove noise from audio with filter
ffmpeg -i <input_file> -af "highpass=f=200, lowpass=f=3000" <output_file>
#or
# ffmpeg -i input.mp4 -af "afftdn=nf=-25" file1.mp4 #bg noise
# ffmpeg -i file1.mp4 -af "afftdn=nf=-25" file2.mp4 # bg noise
# ffmpeg -i file2.mp4 -af "highpass=f=200, lowpass=f=3000" file3.mp4 # speak
# ffmpeg -i file3.mp4 -af "volume=4" finaloutput.mp4 # increase volume
```

## openai-whisper

[doc](https://github.com/openai/whisper)

```sh
# transcribe
whisper test-de.aac --model medium --language de
# transcribe and translate
whisper test-de.aac --model medium --language de --task translate
```

## Text-To-Speech

nix-shell -p tts

## Talon - Spech to Commands

try: [talon](https://xeiaso.net/blog/voice-control-talon)

## infos

- [audio test data: openslr](http://www.openslr.org/12)
- [audio test data: libriVox](https://librivox.org/)
