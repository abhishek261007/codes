# 07 — Pulse Code Modulation (Experiment 8: PCM)

## Objective

Understand PCM end-to-end: how a continuous message is **sampled**, **quantized**
(uniform and non-uniform / mu-law), **encoded to bits**, sent on the line, and
**decoded / reconstructed** at the far end — with all the key formulas verified
in Scilab on a bandlimited sine message.

## Theory

- **Sampling:** a message with highest frequency `fm` must be sampled at
  `fs_s >= 2*fm` (Nyquist). Here `fm = 2 Hz`, `fs_s = 50 Hz` → 50 samples over
  `t in [0, 1) s`. The message is normalized to `[-1, 1]`.
- **Uniform quantization:** with `L = 2^n` levels over `[xmin, xmax]`,
  `delta = (xmax - xmin)/L`. A sample `x` is mapped to cell index
  `q = floor((x - xmin)/delta)`, **clipped** to `[0, L-1]`, and reconstructed as
  `xq = xmin + (q + 0.5)*delta` (cell-centre). This is a *mid-tread-like*
  scheme: with an even number of levels a true mid-tread quantizer (level
  exactly at 0) is impossible, so levels sit at cell centres — a documented
  approximation; the error statistics are unchanged. (A *mid-riser* quantizer
  has a decision boundary at 0 instead. Both quantize fine; only the level
  placement differs.)
- **SQNR rule:** for a **full-range sine** and large `n`,
  `SQNR ≈ 6.02*n + 1.76 dB` (signal power `A^2/2`, error power `delta^2/12`).
  Each extra bit adds ≈ 6.02 dB.
- **Error variance:** for a uniform quantizer with many levels the error is
  flat in `[-delta/2, delta/2]`, with `var(e) = delta^2/12`.
- **Non-uniform (mu-law) companding:** compress first, quantize uniformly,
  expand after decoding:
  `F(x) = sgn(x) * ln(1 + mu*|x|) / ln(1 + mu)`,
  inverse `F^-1(y) = sgn(y) * ((1+mu)^|y| - 1)/mu`.
  ITU-T G.711 uses `mu = 255`. Small signals get finer effective steps;
  large signals get coarser ones. This aids small/weak signals (speech).
- **PCM bit rate:** `R = n * fs_s` bits per second (n bits per sample at fs_s
  samples per second). Example: `50 Hz x 8 bits = 400 bps` here; G.711
  telephony: `8000 Hz x 8 bits = 64000 bps`.
- **Bit depth vs quality:** more bits → smaller delta → higher SQNR, at the
  cost of proportionally more bandwidth.
- **Non-uniform aids small signals:** compression steepens the curve near 0
  (slope `mu/ln(1+mu) ~ 46` for mu = 255), so weak signals occupy more cells.

## Parameter meanings

| Symbol  | Meaning |
|---------|---------|
| `fs_s`  | sampling frequency of the message, 50 Hz (>= 2*fm) |
| `fm`    | message frequency, 2 Hz |
| `t`     | sample instants `(0:fs_s-1)/fs_s`, 50 samples in `[0,1) s` |
| `m`     | message `sin(2*%pi*fm*t)`, normalized to `[-1,1]` |
| `n`     | bits per sample; `L = 2^n` quantization levels |
| `L`     | number of levels (8, 16, 256 in the demos) |
| `xmin, xmax` | assumed signal range, `-1, +1` |
| `delta` | step size `(xmax - xmin)/L` |
| `q`     | level index `floor((m - xmin)/delta)`, clipped to `[0, L-1]` |
| `mq`    | reconstruction `xmin + (q + 0.5)*delta` (cell centre) |
| `e`     | quantization error `m - mq` |
| `mu`    | mu-law companding parameter, 255 |

## How to run

Each file is self-contained and runs from a fresh Scilab session. From this
folder:

```bash
cd /home/abhishek/scilab-communications-lab/07-pcm
scilab -nw -nb -e "exec('quantization.sci', -1)"
```

Replace the filename with any of the seven `.sci` files. Scilab 2024.1, Linux.
A file is healthy when the command exits with code 0 and prints its key
numbers (see below). Plots open in `scf(0)` windows.

## Expected plots and interpretation

1. **quantization.sci** — original sine (blue, markers) vs 3-bit reconstruction
   (red, markers) joined by straight lines. You should see 8 distinct level
   bands. Printed: L = 8, delta = 0.25, MSE ≈ 6.8e-3, measured SQNR ≈ 18.7 dB
   vs 19.82 dB theory. The gap is the small-n breakdown of the 6.02n+1.76 rule.
2. **uniform-quantization.sci** — bar chart of measured SQNR vs n (2, 3, 4, 8)
   with the dashed theory line `6.02n+1.76`. Bars: 12.72, 18.68, 23.99, 49.42 dB
   (theory 13.80, 19.82, 25.84, 49.92). Bars sit slightly BELOW theory; the
   n = 2 case departs most (only 4 levels — the flat-error model fails).
3. **nonuniform-quantization.sci** — sine of amplitude 0.2 (much smaller than
   full scale): original, mu-law-4bit reconstruction, uniform-4bit
   reconstruction on one axes. mu-law SNR ≈ 17.2 dB vs uniform ≈ 13.1 dB
   (≈ +4.1 dB gain). Printed: mu = 255, threshold 1/mu ≈ 0.0039, max
   compressed slope ≈ 45.99, compressed delta = 0.125.
4. **pcm-encoding.sci** — console table of the first 12 samples: index,
   amplitude, level index q, 4-bit code (manual modulo-2 loop, MSB first),
   followed by the concatenated bitstream
   `100010011011110111101111111111111111111011001010` (48 bits). Note that only
   bits go on the line — that is what SerDes serializes/deserializes.
5. **pcm-decoding.sci** — bitstream split into 4-bit words → q → `xmin +
   (q+0.5)*delta` reconstruction, overlaid on the original. Printed: 100 bits,
   12.5 bytes (padded to 13), MSE ≈ 2.0e-3, PCM SQNR ≈ 23.99 dB.
6. **quantization-error.sci** — three stacked subplots: (a) original vs
   4-bit reconstruction; (b) error waveform e(t) (sawtooth-like, bounded by
   ±delta/2 = ±0.0625); (c) unit-area error histogram vs the theoretical
   rectangle pdf of height 1/delta on [-delta/2, delta/2]. Printed: delta =
   0.125, measured var(e) ≈ 2.0e-3 vs delta²/12 ≈ 1.30e-3, measured SQNR
   ≈ 23.99 dB vs 25.84 dB theory. Small excess variance = clipping + coarse cells.
7. **pcm-reconstruction.sci** — three stacked overlays for n = 3 (18.68 dB,
   150 bps), n = 4 (23.99 dB, 200 bps), n = 8 (49.42 dB, 400 bps); the quality
   visibly improves with n; bitrate printed per case (`R = n*fs_s`).

## Observations

- Measured SQNR tracks `6.02n + 1.76` closely for n >= 3, slightly below it, and
  degrades at n = 2 (few-levels regime).
- Clipping to `[0, L-1]` is mandatory: with `floor((x-xmin)/delta)`, a sample
  exactly at +1 yields q = L and would index one level past the array.
- The `+ 0.5*delta` reconstruction offset is not optional — without it the
  quantizer is biased by half a step and the error variance is no longer
  symmetric.
- mu-law companding gives ~4 dB reconstruction gain on a 0.2-amplitude sine
  with only 4 bits.
- The quantization error looks like a sawtooth decorrelated from the signal —
  the classic "white quantization noise" picture.
- PCM bitrate scales linearly with n: 50 Hz × 3/4/8 bits = 150/200/400 bps.

## Common mistakes

- **Clipping outside range** — always `min(max(q, 0), L-1)`; edge samples
  otherwise produce out-of-range indices.
- **Forgetting the delta/2 reconstruction offset** — `xq` must be the cell
  centre `xmin + (q+0.5)*delta`, not `xmin + q*delta`.
- **Using 6.02n+1.76 outside its assumptions** — it is exact only for a
  full-scale sine with many levels; small signals, n = 2, or DC-heavy signals
  all violate it.
- **Confusing mu = 255 with sampling order / confusing companding with
  compression of the bitstream** — mu-law is a *signal* nonlinearity applied
  BEFORE quantization; it is unrelated to fs_s and to source coding.
- **Decoding without the offset** — the receiver reconstructs cell centres;
  omitting `+0.5*delta` biases every level low by half a step.
- **Comparing SQNR of signals with different amplitudes** without saying so —
  the 6.02n+1.76 rule assumes full scale; a 0.2-amplitude sine is not full scale.
- **Treating plot() output as a true staircase** — Scilab joins points with
  straight lines; read the flat bands, not the joins.

## Viva questions (with answers)

1. **Q: State the Nyquist criterion and the fs_s used here.**
   A: A signal bandlimited to fm Hz must be sampled at fs_s >= 2*fm. Here
   fm = 2 Hz, fs_s = 50 Hz — 25× oversampling.

2. **Q: How many levels does n-bit PCM have, and what is delta here for n = 3?**
   A: L = 2^n = 8 levels; delta = (1-(-1))/8 = 0.25.

3. **Q: Derive SQNR = 6.02n + 1.76 dB for a full-range sine.**
   A: Signal power = A²/2 = 0.5 (A = 1). Error ≈ U(-delta/2, delta/2),
   var = delta²/12 = (2/L)²/12 = 1/(3*L²) = 1/(3*2^2n).
   SQNR = (0.5)/(1/(3*2^2n)) = 1.5*2^2n; in dB:
   10*log10(1.5) + 20*n*log10(2) ≈ 1.76 + 6.02n dB.

4. **Q: Why does the formula break at n = 2?**
   A: It assumes many levels and a flat, signal-independent error. At L = 4 the
   error is strongly correlated with the sine and the distribution is far from
   uniform; measured 12.72 dB vs 13.80 dB predicted.

5. **Q: Mid-tread vs mid-riser — which is used here and why?**
   A: A mid-tread-like scheme: reconstruction at cell centres. A true
   mid-tread (level at exactly 0) needs an odd number of levels; with L even
   we place levels at cell centres — the standard even-level approximation.

6. **Q: What is the quantization error variance and its pdf?**
   A: For many levels, e ~ U(-delta/2, delta/2); pdf = 1/delta on that interval;
   var(e) = delta²/12. For delta = 0.125: var ≈ 1.30e-3.

7. **Q: How does mu-law companding improve small-signal SNR?**
   A: F(x) = sgn(x)·ln(1+mu|x|)/ln(1+mu) has slope mu/ln(1+mu) ≈ 46 at 0, so
   tiny inputs are stretched over many cells. After expansion at the receiver
   the quantization noise floor relative to small signals drops. Here a
   0.2-amplitude sine gained ~4 dB with 4 bits.

8. **Q: Why mu = 255 and not some other value?**
   A: ITU-T G.711 standard for North-American telephony PCM; it approximates
   logarithmic companding (≈ 13-segment A-law's mu cousin) and is matched to
   the dynamic range of 16-bit linear audio. A-law (A = 87.6) is the European
   equivalent.

9. **Q: What is the PCM bitrate for fs_s = 50 Hz at 8 bits?**
   A: R = n·fs_s = 8 × 50 = 400 bits/s. (G.711: 8 kHz × 8 bits = 64 kbps.)

10. **Q: What happens on the line if one bit flips in transmission?**
    A: q changes by 2^(position weight): MSB flip → error of 8·delta (here
    catastrophic); LSB flip → one step (0.125). Real links use line coding,
    scrambling, FEC/CRC to bound BER; single-bit errors in PCM degrade gracefully.

11. **Q: Why is the reconstruction offset xmin + (q+0.5)*delta used?**
    A: The decoder knows only the cell, not where in the cell the sample was.
    The cell centre is the minimum-MSE estimate; the half-step offset makes the
    error symmetric around 0 with mean ~ 0.

12. **Q: What is the PCM chain, in one line?**
    A: Sampling (fs_s ≥ 2fm) → quantization (L = 2^n, delta step) → binary
    encoding (n bits/sample) → transmission → decoding → reconstruction
    (cell centres) → optional low-pass interpolation.
