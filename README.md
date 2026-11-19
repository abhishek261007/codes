# Scilab Communication Systems Laboratory & Practice

An undergraduate-oriented collection of standalone Scilab programs for learning Scilab, signals, and communication systems. Programs are organized by topic and intended to run independently with `exec("filename.sci", -1)`.

## Requirements

- Scilab 2024.1 or compatible (Linux)
- No external toolboxes are required for the core laboratory programs.

## Repository contents

| Directory | Contents |
|---|---|
| `00-scilab-fundamentals/` | Variables, arrays, loops, functions, and plotting |
| `01-signal-generation/` | Common periodic signals and operations |
| `02-sampling-and-fft/` | Sampling, aliasing, and spectra |
| `03-amplitude-modulation/` | Conventional AM, DSB-SC, and demodulation |
| `04-frequency-modulation/` | FM generation, spectra, and demodulation |
| `05-noise-and-snr/` | AWGN and SNR demonstrations |
| `06-pulse-modulation/` | PAM, PWM, PPM |
| `07-pcm/` | Quantization and PCM |
| `08-dpcm/` | Differential PCM |
| `09-delta-modulation/` | Delta and adaptive delta modulation |
| `10-line-coding/` | Common digital line codes |
| `11-additional-practice/` | Exercises organized by topic and difficulty |

Each topic directory contains a README with theory, run instructions, expected results, common mistakes, and viva questions.

## Running a program

In Scilab, change to the program's directory and execute it, for example:

```scilab
cd("/path/to/scilab-communications-lab/01-signal-generation")
exec("sine-wave.sci", -1)
```

Plots are produced when running interactively. For execution without a GUI, use `scilab-cli -nwni` (graphics are unavailable in that mode).

## License

MIT; see [LICENSE](LICENSE).
