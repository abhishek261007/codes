# 11 — Additional Practice Programs

This folder is a self-contained practice set for the Scilab Communications Lab. It is meant for an undergraduate ECE student working on **Linux** with **Scilab 2024.1**. Every program is short (40–70 lines), heavily commented, and follows the same layout: header block, a labelled `PARAMETERS` section, the implementation with "why" comments, labelled plots, and `disp()` / `mprintf()` output of the key numeric results. The goal is not to introduce new theory — the theory lives in `theory/` and in the experiment folders — but to give you extra reps on the fundamentals so the lab experiments feel routine instead of magical. Work through the folders in the suggested study order below, run each file, change one parameter at a time, and watch what happens.

## How practice programs are organised

Programs are grouped into subfolders by theme. Each file states its difficulty in the header block (`Difficulty: Beginner|Intermediate|Advanced`).

| Difficulty   | Meaning                                                                                          |
| ------------ | ------------------------------------------------------------------------------------------------ |
| Beginner     | Single concept, direct application of a formula or plotting idiom. Read and run in one sitting.  |
| Intermediate | Two or more concepts combined (e.g. transforms + FFT, or design + analysis). Requires some setup. |
| Advanced     | Multi-stage system or deep analysis (receiver chains, leakage, capacity). Expect 2+ sittings.     |

## Complete difficulty table — all 37 practice programs

| File | Difficulty | Topic | Concepts reinforced |
| ---- | ---------- | ----- | ------------------- |
| rectification/half-wave-rectifier.sci | Beginner | Rectification (half-wave) | Logical masking `x .* (x > 0)`, diode clipping, peak & RMS measurement |
| rectification/full-wave-rectifier.sci | Beginner | Rectification (full-wave) | `abs()` folding, DC average `2*A/pi`, bridge rectifier behaviour |
| signal-transformations/signal-addition.sci | Beginner | Signal addition / superposition | Element-wise ops, superposition principle, RMS of a sum |
| signal-transformations/signal-subtraction.sci | Beginner | Signal subtraction | Difference signals, pi phase flip equivalence |
| signal-transformations/signal-multiplication.sci | Intermediate | Signal multiplication / modulation | Product of cosines, DSB-SC spectrum, single-sided FFT, sideband amplitudes |
| signal-transformations/time-shifting.sci | Intermediate | Time shifting | `x(t - t0)` delay, gated raised-cosine pulse, centroid measurement |
| signal-transformations/time-scaling.sci | Intermediate | Time scaling | `x(2t)` compression vs `x(t/2)` expansion, time support, stretching vs squeezing |
| signal-transformations/time-reversal.sci | Beginner | Time reversal | `x(-t)` mirroring, even-symmetry check `max |x(t)-x(-t)|` |
| signal-transformations/even-odd-decomposition.sci | Intermediate | Even/odd decomposition | `xe = (x(t)+x(-t))/2`, `xo = (x(t)-x(-t))/2`, reconstruction check `x = xe + xo` |
| signal-transformations/energy-power-calculation.sci | Intermediate | Signal energy & power | `E = sum(x.^2)*dt`, `P = mean(x.^2)`, energy vs power signals |
| signal-transformations/rms-calculation.sci | Beginner | RMS value | `sqrt(mean(x.^2))`, sine RMS `A/sqrt(2)`, square-wave RMS, arbitrary arrays |
| frequency-analysis/fft-basics.sci | Beginner | FFT fundamentals | DFT binning, normalisation by N, frequency axis construction |
| frequency-analysis/single-sided-magnitude.sci | Beginner | Single-sided spectra | Doubling one-sided amplitudes, correct DC/Nyquist handling |
| frequency-analysis/multi-tone-analysis.sci | Intermediate | Multi-tone spectra | Peaks at multiple frequencies, bin resolution vs window length |
| frequency-analysis/harmonic-analysis.sci | Intermediate | Harmonics | Fourier series of a periodic waveform, harmonic amplitudes via FFT |
| frequency-analysis/spectral-leakage-windowing.sci | Advanced | Leakage & windowing | Non-coherent sampling, rectangular vs Hann/Hamming windows, scalloping loss |
| modulation-comparisons/am-vs-dsbsc.sci | Intermediate | AM vs DSB-SC | Carrier-containing vs suppressed-carrier modulation, power split, spectra |
| modulation-comparisons/am-vs-fm-comparison.sci | Intermediate | AM vs FM | Amplitude vs angle modulation, bandwidth, noise robustness intuition |
| modulation-comparisons/modulation-index-calculator.sci | Beginner | Modulation index | `mu = Am/Ac`, under/100%/over-modulation regimes |
| modulation-comparisons/nbfm-vs-wbfm.sci | Intermediate | NBFM vs WBFM | Carson's rule, modulation index regimes, bandwidth comparison |
| modulation-comparisons/snr-impact-comparison.sci | Advanced | SNR impact | Effect of channel noise on AM vs FM demodulated output, SNR measurement |
| mixed-exercises/basic-math-operations.sci | Beginner | Basic math | Arithmetic operators, precedence, `%pi`, `%e` |
| mixed-exercises/vector-operations-practice.sci | Beginner | Vector operations | Element-wise `.* ./ .^`, indexing, `linspace`, `zeros`/`ones` |
| mixed-exercises/loop-practice.sci | Beginner | Loops | `for` loops, accumulators, iteration patterns |
| mixed-exercises/conditional-practice.sci | Beginner | Conditionals | `if/elseif/else/end`, relational operators `<>` |
| mixed-exercises/function-practice.sci | Beginner | Functions | `function [out] = name(args) ... endfunction`, multiple outputs |
| mixed-exercises/signal-generation-practice.sci | Beginner | Signal generation | Sine, square, sawtooth, triangular waveforms from scratch |
| mixed-exercises/aliasing-deep-dive.sci | Intermediate | Aliasing | Nyquist criterion, folding frequency, undersampling artefacts |
| mixed-exercises/quantization-comparison.sci | Intermediate | Quantization | Uniform quantization, quantization error, SNR vs bits |
| mixed-exercises/binary-encoding-practice.sci | Intermediate | Binary encoding | Natural binary, Gray code, two's complement practice |
| mixed-exercises/pulse-generation-practice.sci | Intermediate | Pulse generation | PAM/PWM/PPM pulse trains from a message signal |
| mixed-exercises/line-coding-practice.sci | Intermediate | Line coding | Unipolar NRZ, polar NRZ, Manchester, AMI basics |
| mixed-exercises/am-receiver-chain.sci | Advanced | AM receiver chain | Modulator → channel noise → envelope/synchronous detector → message recovery, stage-by-stage SNR |
| mixed-exercises/fm-receiver-chain.sci | Advanced | FM receiver chain | VCO/integrator discriminator, FM generation and demodulation with noise, bandwidth trade-off |
| mixed-exercises/dpcm-vs-pcm-comparison.sci | Advanced | DPCM vs PCM | Differential prediction, bit-rate savings, SQNR comparison at equal rate |
| mixed-exercises/adaptive-delta-mod-advanced.sci | Advanced | Adaptive delta modulation | Step-size adaptation (syllabic/instantaneous), slope overload vs granular noise |
| mixed-exercises/channel-capacity-snr.sci | Advanced | Channel capacity vs SNR | Shannon–Hartley `C = B*log2(1+SNR)`, waterfall curves, bandwidth/SNR trade-off |

## How to run a practice program

Interactive (plots appear):

```bash
cd /home/abhishek/scilab-communications-lab/11-additional-practice/rectification
scilab-cli -nwni -f full-wave-rectifier.sci   # or open in the Scilab desktop, Ctrl+L
```

For headless / windowless testing (no figure window is opened; graphics calls are shadowed by no-op stubs):

```bash
timeout 120 scilab-cli -nwni -nb -quit \
  -e "exec('/tmp/opencode/noop_graphics.sci', -1); exec('full-wave-rectifier.sci', -1)"
```

In the headless log, output mentioning `scf`, `plot`, etc. is expected to be silent (those are no-ops). Any line containing `at line` or `Error` indicates a real bug — fix it before moving on.

## Suggested study order

1. **Foundations first**: `mixed-exercises/basic-math-operations.sci` → `vector-operations-practice.sci` → `loop-practice.sci` → `conditional-practice.sci` → `function-practice.sci` → `signal-generation-practice.sci`. These make you fluent in the Scilab idioms used everywhere else.
2. **Core signal skills**: `rectification/*`, `signal-transformations/rms-calculation.sci`, `energy-power-calculation.sci`, `time-reversal.sci`, `signal-addition.sci`, `signal-subtraction.sci`.
3. **Transformations**: `time-shifting.sci`, `time-scaling.sci`, `even-odd-decomposition.sci`, `signal-multiplication.sci`.
4. **Frequency domain**: `fft-basics.sci` → `single-sided-magnitude.sci` → `multi-tone-analysis.sci` → `harmonic-analysis.sci` → `spectral-leakage-windowing.sci`.
5. **Modulation**: `modulation-index-calculator.sci` → `am-vs-dsbsc.sci` → `nbfm-vs-wbfm.sci` → `am-vs-fm-comparison.sci` → `snr-impact-comparison.sci`.
6. **Digital & systems**: `aliasing-deep-dive.sci` → `quantization-comparison.sci` → `binary-encoding-practice.sci` → `pulse-generation-practice.sci` → `line-coding-practice.sci` → `dpcm-vs-pcm-comparison.sci` → `adaptive-delta-mod-advanced.sci` → `am-receiver-chain.sci` → `fm-receiver-chain.sci` → `channel-capacity-snr.sci`.

If you are short on time, do every **Beginner** file first, then **Intermediate**, then **Advanced**.

## Mapping to lab experiments

| Practice file | Lab section |
| ------------- | ----------- |
| mixed-exercises/basic-math-operations.sci | 00-scilab-fundamentals |
| mixed-exercises/vector-operations-practice.sci | 00-scilab-fundamentals |
| mixed-exercises/loop-practice.sci | 00-scilab-fundamentals |
| mixed-exercises/conditional-practice.sci | 00-scilab-fundamentals |
| mixed-exercises/function-practice.sci | 00-scilab-fundamentals |
| mixed-exercises/signal-generation-practice.sci | 01-signal-generation |
| signal-transformations/signal-addition.sci | 01-signal-generation |
| signal-transformations/signal-subtraction.sci | 01-signal-generation |
| signal-transformations/signal-multiplication.sci | 01-signal-generation, 03-amplitude-modulation |
| rectification/half-wave-rectifier.sci | 01-signal-generation (waveform shaping) / 03-amplitude-modulation (envelope detection) |
| rectification/full-wave-rectifier.sci | 01-signal-generation (waveform shaping) / 03-amplitude-modulation (envelope detection) |
| frequency-analysis/fft-basics.sci | 02-sampling-and-fft |
| frequency-analysis/single-sided-magnitude.sci | 02-sampling-and-fft |
| frequency-analysis/multi-tone-analysis.sci | 02-sampling-and-fft |
| frequency-analysis/harmonic-analysis.sci | 02-sampling-and-fft |
| frequency-analysis/spectral-leakage-windowing.sci | 02-sampling-and-fft |
| mixed-exercises/aliasing-deep-dive.sci | 02-sampling-and-fft |
| modulation-comparisons/modulation-index-calculator.sci | 03-amplitude-modulation, 04-frequency-modulation |
| modulation-comparisons/am-vs-dsbsc.sci | 03-amplitude-modulation |
| modulation-comparisons/am-vs-fm-comparison.sci | 03-amplitude-modulation, 04-frequency-modulation |
| modulation-comparisons/nbfm-vs-wbfm.sci | 04-frequency-modulation |
| modulation-comparisons/snr-impact-comparison.sci | 05-noise-and-snr |
| signal-transformations/rms-calculation.sci | 05-noise-and-snr |
| signal-transformations/energy-power-calculation.sci | 05-noise-and-snr |
| signal-transformations/time-shifting.sci | 01-signal-generation (transformations) |
| signal-transformations/time-scaling.sci | 01-signal-generation (transformations) |
| signal-transformations/time-reversal.sci | 01-signal-generation (transformations) |
| signal-transformations/even-odd-decomposition.sci | 01-signal-generation (transformations) |
| mixed-exercises/pulse-generation-practice.sci | 06-pulse-modulation |
| mixed-exercises/quantization-comparison.sci | 07-pcm, 08-dpcm |
| mixed-exercises/binary-encoding-practice.sci | 07-pcm |
| mixed-exercises/line-coding-practice.sci | 10-line-coding |
| mixed-exercises/dpcm-vs-pcm-comparison.sci | 07-pcm, 08-dpcm |
| mixed-exercises/adaptive-delta-mod-advanced.sci | 09-delta-modulation |
| mixed-exercises/am-receiver-chain.sci | 03-amplitude-modulation, 05-noise-and-snr |
| mixed-exercises/fm-receiver-chain.sci | 04-frequency-modulation, 05-noise-and-snr |
| mixed-exercises/channel-capacity-snr.sci | 05-noise-and-snr (noise/SNR foundations for information theory) |
