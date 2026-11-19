# 02 — Sampling and FFT (Experiment 2)

## Objective
Learn how a continuous message is converted into discrete samples, how the sampling rate relative to the message bandwidth decides whether the original can ever be recovered (aliasing), and how to read amplitude and frequency information out of a sampled signal using the Fast Fourier Transform (FFT). Every program is self-contained, prints its key numbers, and can be run fresh in the Scilab console.

## Theory

**Nyquist sampling theorem.** A band-limited message with highest frequency `fm` is uniquely recoverable from its samples only if the sampling frequency satisfies `fs >= 2*fm`. The rate `2*fm` is the Nyquist rate; `fs/2` is the Nyquist frequency (the folding frequency).

**Aliasing.** Any frequency component `f` above `fs/2` appears in the sampled data at

```
f_alias = |f - k*fs|
```

where `k` is the integer that folds `f` into `[0, fs/2]`. Once aliased, the component is indistinguishable from a genuine baseband tone — the damage is permanent, which is why an anti-alias low-pass filter precedes every ADC.

**Ideal vs natural vs flat-top sampling.**
- *Ideal (impulse) sampling*: `xs(t) = m(t) * sum_n delta(t - nTs)` — zero-width impulses. The spectrum is an exact copy of the message spectrum at every `k*fs`: `Xs(f) = (1/Ts) * sum_k X(f - k*fs)`. This is the theoretical reference.
- *Natural sampling*: `m(t)` is multiplied by a rectangular pulse train; the pulse **tops follow the message** during the pulse width. No aperture (sinc) distortion, easy to analyze.
- *Flat-top (sample-and-hold) sampling*: the pulse top is **held flat** at `m(nTs)` across the whole pulse width. Simple to build with a hold circuit, but introduces aperture distortion (a sinc roll-off multiplying the spectrum).

**FFT scaling (single-sided).** For an N-point FFT of `x` sampled at `fs`:

```
frequency axis:        f  = (0:N/2) * fs / N          (N/2+1 bins, 0 .. fs/2)
single-sided amplitude: A = 2*|X[k]| / N               for interior bins
DC bin   (k=0):        A = |X[0]| / N                 NOT doubled
Nyquist  (k=N/2):      A = |X[N/2]| / N              NOT doubled (even N)
```

The factor 2/N folds the negative-frequency half of the spectrum onto the positive half. For real inputs `X[N-k] = conj(X[k])`, so information is genuinely duplicated — doubling is required everywhere **except** DC and Nyquist.

**Frequency resolution.** `Δf = fs / N`. To land a tone exactly on a bin, the signal duration `N/fs` must contain an integer number of cycles of that tone; otherwise spectral leakage spreads energy into neighbouring bins.

## Parameter meanings

| Name | Meaning | Typical units / values |
|---|---|---|
| `fm` | message (tone) frequency | Hz, 5–120 Hz in these demos |
| `Am` | message amplitude | V |
| `fs` / `fs_s` | sampling frequency | Hz (10–10000 Hz across the demos) |
| `Ts = 1/fs_s` | sampling period | s |
| `fs_hi` | fine grid used only to *draw* waveforms | Hz, 1000–10000 |
| `N` | FFT length (number of samples) | samples; also = signal duration in seconds at fs samples/s |
| `duty` | pulse width as a fraction of `Ts` (natural sampling) | 0.3 (30%) |
| `df = fs/N` | frequency resolution of the FFT | Hz (e.g. 1 Hz for fs=1000, N=1000) |
| `f_alias` | apparent (folded) frequency | Hz |

## How to run

Open a terminal in this folder and run any program with:

```sh
scilab -nw -nb -e "exec('natural-sampling.sci', -1)"
```

Or from the Scilab console, `cd` into this directory and type `exec("natural-sampling.sci", -1)`. Each file is self-contained: it creates its own figures (`scf`), prints key numbers with `disp`/`mprintf`, and exits cleanly. No files are written and no figure exports are performed.

## Expected plots and interpretation

1. **natural-sampling.sci** — Figure 1: three stacked panels (message, pulse train, overlaid sampled result). Figure 2: marker-plus sample values on the message. Expect `fs_s = 40 Hz`, Nyquist 20 Hz, sample values `cos(2*pi*10*n/40) = cos(pi*n/2)` = 1, 0, -1, 0, ...
2. **ideal-sampling-demo.sci** — Figure 1: message, impulse train (drawn as 2%-wide pulses), exact sample stems. Figure 2: spectrum with copies centred at 0, 40, 80, 120, ... Hz with baseband tone at 10 Hz — this is `Xs(f) = (1/Ts) * sum_k X(f - k*fs_s)` made visible.
3. **undersampling.sci** — Two panels: 40 Hz message with its 50 Hz samples, and the identical samples lying on a 10 Hz cosine. `disp` prints `f_alias = |40 - 1*50| = 10 Hz`.
4. **nyquist-sampling.sci** — Figure 1: cosine sampled at exactly 10 Hz (samples hit ±1 for a cosine; a sine would read all zeros). Figure 2: same message sampled at 25 Hz, densely traced. Comment in-file discusses the phase ambiguity at exactly `2*fm`.
5. **oversampling.sci** — One figure: 5 Hz message (dashed) with 200 Hz samples (circles joined by lines) — the reconstruction is nearly trivial and the anti-alias filter can be very gentle.
6. **aliasing-demonstration.sci** — Figure 1: 5 Hz and 495 Hz cosines with their samples at 500 Hz (identical sequences). Figure 2: both FFTs peak in the same 5 Hz bin. `max|x1 - x2| ≈ 0`.
7. **fft-single-tone.sci** — Single-sided magnitude vs 0–500 Hz, one spike at 50 Hz. Console prints `f_peak = 50.00 Hz`, measured amplitude ≈ 1.0000, `df = 1.00 Hz`.
8. **fft-multiple-tones.sci** — Two spikes: 50 Hz at amplitude 1.0, 120 Hz at amplitude 0.5. Console prints both measured peaks. `N = 1000` contains an integer number of both cycles, so there is no leakage.
9. **single-sided-spectrum.sci** — Two panels: raw two-sided `|X(f)|/N` (cosine shows as two symmetric bumps at ±50 Hz, DC at 0), then the single-sided spectrum after subtracting the measured DC (`mean(x) ≈ 1.5 V`). Console prints the true/measured DC and the recovered 50 Hz peak amplitude.

## Observations

- Sampling below `2*fm` does not distort the samples in any obvious way — it silently re-labels the frequency. The only defence is an anti-alias filter *before* the sampler.
- At exactly `fs = 2*fm` the spectrum copies touch at `fs/2`; any non-ideal filter or phase misalignment causes aliasing, and the sample set can lose the signal entirely (sine case).
- Oversampling buys relaxed filter specs and easier reconstruction at the cost of more data.
- The FFT is only as honest as its axis labels: `f = (0:N/2)*fs/N` and the `2/N` scaling (DC/Nyquist excluded) are mandatory for calibrated voltage readings.
- Leakage vanishes only when the window holds an integer number of cycles; otherwise use a window function and accept wider peaks.

## Common mistakes

1. **`plot(fft(x))` with no frequency axis** — you get magnitude vs bin index, not Hz. Always build `f = (0:N/2)*fs/N` and label the x-axis.
2. **Forgetting the `2/N` scaling** — every non-DC amplitude comes out twice too small (or you double DC by mistake too).
3. **Doubling the Nyquist bin** — for even N, `X[N/2]` is its own mirror image and must not be doubled; same for DC.
4. **Running `fs` barely above `2*fm`** — leaves no room for the anti-alias filter transition band; a tone slightly mis-estimated by the filter design aliases anyway. Leave headroom (2.5x–10x, or a guard band).
5. **Assuming aliasing changes sample values** — it does not. Samples of a 495 Hz cosine at 500 Hz are *bit-identical* to samples of a 5 Hz cosine.
6. **Judging leakage by eye without checking integer cycles** — if `N` is not a multiple of the period, peak-bin amplitude is underestimated; the tone is still there, smeared.
7. **Confusing two-sided and single-sided plots** — a real cosine's energy lives at ±f/N each; plotting `abs(fft(x))/N` for half the axis under-reads amplitude by 2x.

## Viva questions with answers

**Q1. State the Nyquist sampling theorem.**
A band-limited signal with maximum frequency `fm` can be perfectly reconstructed from its samples iff the sampling frequency `fs >= 2*fm`. The minimum rate `2*fm` is the Nyquist rate; `fs/2` is the Nyquist (folding) frequency.

**Q2. What is aliasing and how is it avoided?**
Spectral copies at `k*fs` overlap when `fs < 2*fm`; a high-frequency component appears at `f_alias = |f - k*fs|` below `fs/2`. Avoided by (a) keeping `fs > 2*fm` with margin and (b) an anti-alias low-pass filter before the sampler.

**Q3. A 40 Hz tone is sampled at 50 Hz. Where does it appear?**
`k = round(40/50) = 1`, `f_alias = |40 - 50| = 10 Hz`. Samples are identical to those of a 10 Hz cosine: `cos(2*pi*0.8*n) = cos(2*pi*0.2*n)`.

**Q4. Why must DC and the Nyquist bin not be doubled in a single-sided FFT?**
Because of conjugate symmetry `X[N-k] = conj(X[k])`. Interior bins pair up (+k, -k), so doubling recovers the full magnitude. DC (k=0) and, for even N, the Nyquist bin (k=N/2) are self-conjugate — they have no partner to fold in, so doubling them would count them twice.

**Q5. Derive the single-sided amplitude formula `A = 2|X[k]|/N`.**
For `x[n] = A cos(2*pi*k*n/N)`, the DFT gives `X[k] = X[N-k] = N*A/2`. Hence `A = 2|X[k]|/N`. For a general real signal the same linear superposition applies bin-by-bin. DC: `X[0] = sum x[n] = N*DC`, so `DC = |X[0]|/N` with no factor 2.

**Q6. What is frequency resolution and how do you improve it?**
`Δf = fs/N` — the spacing between adjacent FFT bins. Improve it by increasing N (longer observation window) at fixed fs, since `Δf = 1/T_window`; zero-padding interpolates but does not add information.

**Q7. What is spectral leakage and when does it not occur?**
Leakage is the spreading of a tone's energy into neighbouring bins when the observation window does not contain an integer number of cycles (the DFT assumes periodic extension, and the discontinuity at the wrap-around leaks). It vanishes when `f0*N/fs` is an integer. Otherwise apply a window (Hann/Hamming/Blackman) at the cost of a wider main lobe.

**Q8. Compare ideal, natural, and flat-top sampling.**
Ideal: zero-width impulses, exact spectral copies at `k*fs`, no distortion — theoretical reference. Natural: rectangular pulses, pulse tops track `m(t)`, spectrum carries a sinc envelope but no aperture error, moderately easy to build. Flat-top: pulse tops held at `m(nTs)`, introduces aperture distortion (sinc roll-off) but is the simplest sample-and-hold circuit; both real samplers need an anti-alias filter and slight spectral correction by the sinc.

**Q9. Can sampling at exactly `fs = 2*fm` always recover `m(t)`?**
No. In theory only for perfectly band-limited signals with nothing at exactly `fm` and ideal brick-wall filters. Practically it fails: a sine sampled at its zero crossings reads all zeros; phase/amplitude information is ambiguous, and any filter transition band aliases. Always sample above `2*fm`.

**Q10. Why do oversampling systems (e.g. sigma-delta ADCs) tolerate sloppy anti-alias filters?**
With fs far above 2*fm, the nearest alias sits far above the baseband, so the anti-alias filter can have a wide, gentle transition band (a simple RC may suffice). Oversampling also spreads quantization noise over a wider bandwidth, lowering the noise floor in-band after decimation. Trade-off: more samples and a faster converter.
