# 03 — Amplitude Modulation (Experiment 3: DSB-SC & DSB-C AM)

Scilab 2024.1 | Linux | Undergraduate ECE — Communication Systems

This folder contains ten self-contained, executable Scilab programs (`.sci`)
experimenting with amplitude modulation: generation, modulation index,
under/100%/over-modulation, DSB-SC and DSB-C (full-carrier) AM, envelope and
synchronous demodulation, and the frequency spectrum.

## Objective

1. Generate and visualise conventional (full-carrier / DSB-C) AM and DSB-SC.
2. Understand modulation index μ from envelope extrema and from measurement.
3. See why μ ≤ 1 is mandatory for the envelope detector, and what breaks at μ = 1 and μ > 1.
4. Recover the message with (a) an envelope detector and (b) a synchronous (product) detector.
5. Read the spectrum: carrier line and sidebands at fc ± fm; DSB-SC has no carrier line.

## Theory

### Conventional AM (DSB-LC = DSB-C, "double sideband with carrier")

```
s(t) = Ac * (1 + mu * m_n(t)) * cos(2*pi*fc*t)
```

where `m_n(t)` is the **normalised** message, |m_n(t)| ≤ 1. With a single-tone
message m(t) = Am·cos(2*pi*fm*t) and m_n = m/Am (i.e. Am = 1, or μ = Am/Ac for
pure "Am-based" modulation index):

```
s(t) = Ac*cos(wc t)                                  <- carrier term
     + (mu*Ac/2) * [cos((wc+wm) t) + cos((wc-wm) t)]   <- sidebands at fc ± fm
```

Envelope (upper): `e(t) = Ac*(1 + mu*m_n(t))`, always ≥ 0 **iff μ ≤ 1**.

### Power relations (Ac across a unit resistance, amplitudes are peaks)

```
Pc   = Ac^2 / 2                       (carrier power)
Pusb = Plsb = mu^2 * Ac^2 / 8         (each sideband)
Ps   = Pusb + Plsb = mu^2 * Ac^2 / 4  (total sideband power)
Ptot = Pc + Ps = (Ac^2 / 2) * (1 + mu^2/2)
Carrier/sideband ratio = 2 / mu^2     (e.g. mu = 0.5 -> 8)
Transmission efficiency eta = Ps / Ptot = mu^2 / (2 + mu^2)   (mu = 1 -> 33.3%)
```

All power beyond carrier is carried by the sidebands; that is why the carrier
(present at 66–90% of total power) is used only to permit simple envelope detection.

### DSB-SC (double sideband, suppressed carrier)

```
s(t) = Ac * m(t) * cos(2*pi*fc*t)
     = Ac/2 * [cos((wc+wm) t) + cos((wc-wm) t)]
```

No carrier term → no power wasted → η = 100%, but the **phase reverses** every time
m(t) crosses zero, so `|s(t)|` folds and an envelope detector cannot recover m(t).
Requires synchronous (coherent) detection. Note: **DSB-C and conventional AM
(DSB-LC) are the same signal** — "DSB with carrier" is simply full-carrier AM.

### Modulation index

Two equivalent views:

```
mu = Am / Ac                       (single-tone, normalized message)
mu = (Amax - Amin) / (Amax + Amin) (from envelope extrema - used to measure mu)
```

μ < 1: under-modulation (envelope above zero). μ = 1: envelope touches zero.
μ > 1: over-modulation — envelope expression goes negative; envelope detector distorts.

### Detection

* **Envelope (non-coherent):** rectify `|s(t)|`, then low-pass (moving average of
  L ≈ fs/fc samples passes fm and rejects 2·fc ripple). Simple, no carrier recovery,
  **but requires μ ≤ 1**. Fails silently at μ > 1.
* **Synchronous (coherent):** multiply by local carrier cos(2*pi*fc*t + phi), low-pass.
  `s(t)·cos(wc t) = Ac/2*(1+mu*mn) + Ac/2*(1+mu*mn)*cos(2wc t)` → LP keeps
  `Ac/2 + (mu*Ac/2)*cos(wm t)`; after DC removal, a scaled m(t). Works for **any μ**,
  including over-modulation and DSB-SC. Cost: needs a phase-coherent local oscillator.

## Parameter meanings

| Symbol | Meaning | Value here |
|--------|---------|------------|
| `fs`   | Sampling frequency (must be ≫ 2*fc; 2*fc = 400 Hz) | 10000 Hz |
| `fm`   | Message (modulating) frequency | 10 Hz |
| `fc`   | Carrier frequency | 200 Hz |
| `Ac`   | Carrier amplitude | 1 V |
| `Am`   | Message amplitude | 1 V |
| `mu`   | Modulation index | 0.3 / 0.5 / 0.7 / 1.0 / 1.5 |
| `m_n`  | Normalised message, |m_n| ≤ 1 | `cos(2*pi*fm*t)` |
| `L`    | Moving-average LP length (= round(fs/fc) ≈ 50) | 50 samples |
| `fs_spec` | FFT sampling rate for spectra (N = 10000) | 10000 Hz |

Global rules respected: `fs >> 2*fc`; spectra use `fs_spec = 10000, N = 10000`
→ 1 Hz bin spacing, integer cycles (fm: 100, fc: 2000) → no spectral leakage;
single-sided magnitude scaling `X1 = 2*|fft(x)|/N`, DC and Nyquist not doubled.

## Block diagram

```
                 ┌──────────┐
   m(t) ────────►│          │
                 │  Sum/    │     ┌───────────────┐      ┌─────────┐
 Ac·cos(wc t) ──►│  Mixer / ├────►│  AM signal    ├─────►│ Channel │
  (DC offset     │  Product │     │  s(t)         │      └────┬────┘
   for DSB-C)    └──────────┘     └───────────────┘           │
                                                              ▼
   ┌──────────────────────────────────────┐   ┌─────────────────────────────────┐
   │  Envelope detector (AM / DSB-C only) │   │  Synchronous demodulator        │
   │  s(t) → |s(t)| → moving-average LP   │   │  s(t) × cos(wc t + φ) → LP      │
   │  → recover m(t)   (needs μ ≤ 1)      │   │  → DC block → recover m(t)      │
   └──────────────────────────────────────┘   │  (works for any μ, DSB-SC too)  │
                                              └─────────────────────────────────┘
```

## How to run

```bash
cd /home/abhishek/scilab-communications-lab/03-amplitude-modulation
scilab -nw -nb -e "exec('am-generation.sci', -1)"
# ... or open the .sci in the Scilab desktop and press Ctrl+L (execute)
```

Every program is batch-clean: `timeout 120 scilab -nw -nb -e "exec('FILE.sci', -1)"`
exits with code 0 and prints its key numbers via `disp`/`mprintf`.

## Expected plots and interpretation

| File | What you see | Interpretation |
|------|--------------|----------------|
| `am-generation.sci` | (1) message + faint carrier, (2) AM waveform, (3) s(t) with ±envelope dashed | Carrier amplitude waxing/waning with the message; envelope ≥ 0 at μ = 0.5. |
| `am-modulation-index.sci` | AM signal with recovered dashed envelope overlay | Detector recovers envelope; μ_measured ≈ 0.697 vs 0.7 true (small LP ripple). |
| `under-modulation.sci` | 3 subplots: message / AM / recovered vs true scaled message | Envelope comfortably above zero; detection clean. |
| `100-percent-modulation.sci` | envelope touches zero at troughs; recovered ripples there | Marginal: noise causes diagonal clipping; transmitters keep μ ≤ 0.5–0.8. |
| `over-modulation.sci` | signed envelope crosses zero; s(t) phase reverses; detector output folds | Envelope detection impossible — must use synchronous demodulation. |
| `dsb-sc-generation.sci` | message, carrier, DSB-SC with |s(t)| folded overlay | No carrier term; |s| folds at each of the 8 message zero crossings. |
| `dsb-c-generation.sci` | AM with true (black) and recovered (green) envelopes | DSB-C = conventional AM; prints carrier:sideband power ratio 8, η = 11%. |
| `am-envelope-detection.sci` | s(t); message vs rescaled recovered envelope | Correlation ≈ 0.988 (limited by causal LP group delay, cos(2π·fm·2.5 ms)); μ ≤ 1 required. |
| `am-synchronous-demodulation.sci` | two overlays: μ = 0.5 and μ = 1.5 | Synchronous demod recovers m(t) with corr ≈ 0.99 in BOTH cases, incl. over-modulation. |
| `am-frequency-spectrum.sci` | 3 spectra: message, AM, DSB-SC (single-sided, annotated) | AM: 1.0 V line @ 200 Hz + 0.25 V lines @ 190/210 Hz; DSB-SC: only 0.5 V lines @ 190/210 Hz, nothing at 200 Hz. |

## Observations

1. Conventional AM spends most of its power in the carrier (2/μ² = 8× sideband power
   at μ = 0.5); efficiency η = μ²/(2+μ²) is only 11% at μ = 0.5, 33% at μ = 1.
2. The envelope detector is a *nonlinear* device that is linear only when the
   envelope never goes negative — i.e. μ ≤ 1. At μ = 1 it is marginal; at μ > 1 it fails.
3. Synchronous demodulation is *linear*; it works at any μ and is mandatory for DSB-SC.
4. Rectification creates ripple at 2·fc and its harmonics; a moving average of
   L = fs/fc = 50 nulls them exactly (integer ratio) while passing fm = 10 Hz.
5. Correlation ≈ 0.988 with the causal moving average is expected: the filter's
   L/2 = 25-sample group delay shifts a 10 Hz message by 2.5 ms (cos(2π·10·0.0025) ≈ 0.988).
6. FFT with N = 10000, fs_spec = 10000 gives exact 1 Hz bins; all tones are
   integer-cycle, so spectra are pure impulse lines (carrier 200 Hz amplitude 1.0;
   sidebands μ·Ac/2 = 0.25 V for AM, Ac/2 = 0.5 V for DSB-SC).

## Common mistakes

1. **Forgetting the DC offset term.** Conventional AM is `Ac*(1 + mu*mn)*cos(...)`, NOT
   `Ac*mn*cos(...)` (that is DSB-SC). Without the "1 +", there is no carrier and no envelope.
2. **Using |m(t)| as "the envelope" for μ > 1.** It folds: min(|1 + μ·cos|) ≈ 0 and
   the detector output is a rectified version of (1+μ·cos), not a scaled copy of m(t).
3. **FFT without a frequency axis or proper scaling.** Always plot f = (0:N/2)*fs/N and
   use 2*|fft(x)|/N (single-sided), not |fft(x)|, or amplitudes will be off by 2×.
4. **Confusing DSB-SC with ordinary AM.** DSB-SC has NO line at fc; AM does. DSB-SC
   cannot be envelope-detected; AM can (for μ ≤ 1).
5. **Envelope detector failing silently at μ > 1.** It produces a plausible-looking but
   wrong waveform (phase-reversal folding) instead of an error message — check μ first.
6. **Not removing the Ac/2 DC term** after synchronous detection; the output looks
   offset and its peak is misread. Subtract `mean(y)` or AC-couple.
7. **Spectral leakage** from non-integer cycles (fm·T not integer, or N too small).
   Here fm = 10 Hz and N = 10000 → exactly 100 cycles — avoid half-bin tones.
8. **Doubling the DC/Nyquist bins** in single-sided scaling — they have no mirror image.
9. **fs < 2*fc** — aliasing; here fs = 10000 Hz ≫ 2*fc = 400 Hz, always satisfied.
10. **Mixing up peak and RMS amplitudes** in power formulas (Pc = Ac²/2 uses peak Ac).

## Comparison table — AM / DSB-C vs DSB-SC

| Property | Conventional AM / DSB-C (DSB-LC) | DSB-SC |
|----------|----------------------------------|--------|
| Signal | `Ac(1 + μ·mn)cos(wc t)` | `Ac·m(t)·cos(wc t)` |
| Carrier present? | **Yes** (line at fc) | **No** (suppressed at generator) |
| Sidebands | fc ± fm, amplitude μ·Ac/2 | fc ± fm, amplitude Ac·Am/2 (= Ac/2) |
| Carrier power wasted? | Yes — 2/μ² × sideband power | No — 0 |
| Transmission efficiency η = Ps/Ptot | μ²/(2+μ²) (≤ 33.3%) | **100%** |
| Envelope detection? | **Yes** (μ ≤ 1 required) | **No** (envelope folds) |
| Synchronous detection? | Yes (any μ) | **Yes (only way)** |
| Receiver complexity | Very simple (crystal radio) | Complex (coherent local oscillator + PLL) |
| Selective fading immunity | Poor | Better with coherent detection |
| Typical use | AM broadcast radio | Analogue TV vision carrier partly suppressed (VSB), SSC systems |

## Viva questions (with answers)

**Q1.** Write the expression for conventional AM and expand it.
**A.** `s(t) = Ac(1 + μ·mn)cos(wc t)`. With mn = cos(wm t): `s(t) = Ac·cos(wc t) + (μAc/2)[cos((wc+wm)t) + cos((wc−wm)t)]` — carrier plus two sidebands.

**Q2.** What is the modulation index and how is it measured from the envelope?
**A.** μ = Am/Ac (single tone). From the envelope, μ = (Amax − Amin)/(Amax + Amin); Amax = Ac(1+μ), Amin = Ac(1−μ). Verified in `am-modulation-index.sci` (0.697 measured vs 0.7 set).

**Q3.** Why must μ ≤ 1 for envelope detection?
**A.** The envelope Ac(1+μ·cos) becomes negative for μ > 1, meaning the "outline" of s(t) crosses zero; the RF phase reverses by 180°. The rectified envelope then folds (`|envelope|` has a V-shape at the nulls), so the detector output is a distorted, non-linear image of m(t).

**Q4.** What happens at exactly μ = 1?
**A.** Envelope just touches zero at message troughs. Detection works on a noiseless signal but is marginal — any noise near the nulls clips (diagonal clipping). Practical μ ≤ 0.8.

**Q5.** Why does the envelope detector need no carrier synchronisation?
**A.** Because the carrier term Ac·cos(wc t) in full-carrier AM is transmitted, its amplitude oscillation IS the message; rectification + low-pass reads that amplitude directly. No local oscillator needed.

**Q6.** Why can't DSB-SC use an envelope detector?
**A.** s(t) = Ac·m(t)cos(wc t) has no carrier; |s(t)| = |Ac·m(t)| folds at every message zero crossing, giving a full-wave-rectified |m(t)|, not m(t). Hence coherent detection is mandatory.

**Q7.** How does a synchronous demodulator work?
**A.** Multiply s(t) by a local carrier cos(wc t + φ). With φ = 0: s·cos(wc t) = Ac/2·(1+μ·mn) + Ac/2·(1+μ·mn)cos(2wc t). The LP removes the 2·fc terms; after DC-blocking, output = (μAc/2)·mn — a scaled replica of m(t), valid for any μ (see `am-synchronous-demodulation.sci`, μ = 1.5 recovered with corr ≈ 0.99).

**Q8.** What is the effect of a phase error φ in the local oscillator?
**A.** Output becomes (μAc/2)·mn·cos(φ) — same waveform scaled by cos φ. φ = 90° kills the signal entirely. That is why a PLL or pilot carrier is used to keep φ ≈ 0.

**Q9.** Compute the carrier-to-sideband power ratio and efficiency for μ = 0.5.
**A.** Pc = Ac²/2, Ps = μ²Ac²/4 = Ac²/16. Ratio Pc/Ps = 8. η = Ps/(Pc+Ps) = μ²/(2+μ²) = 0.111 ≈ 11%.

**Q10.** Why is DSB-SC 100% efficient?
**A.** All transmitted power is in the sidebands (no carrier at all), and the sidebands are exactly the terms containing the message. η = Ps/Ptot = 1.

**Q11.** Identify the spectral lines of AM (μ = 0.5) and DSB-SC from the FFT output.
**A.** AM: 1.0 V at 200 Hz (carrier), 0.25 V each at 190 and 210 Hz. DSB-SC: 0.5 V each at 190 and 210 Hz, nothing at 200 Hz. Single-sided scaling 2·|FFT|/N (see `am-frequency-spectrum.sci`).

**Q12.** Why move-average length L = fs/fc ≈ 50 for the demodulator LP?
**A.** It must pass fm = 10 Hz (period 1000 samples ≫ 50) and reject the rectified carrier ripple at 2·fc = 400 Hz. With L = fs/fc = 50, the MA response has exact nulls at k·(fs/L) = k·200... in practice it nulls the 400 Hz harmonic family for integer ripple cycles, passing the message essentially unchanged — verified by corr ≈ 0.99.

---

### File inventory (10 programs)

`am-generation.sci` · `am-modulation-index.sci` · `under-modulation.sci` ·
`100-percent-modulation.sci` · `over-modulation.sci` · `dsb-sc-generation.sci` ·
`dsb-c-generation.sci` · `am-envelope-detection.sci` · `am-synchronous-demodulation.sci` ·
`am-frequency-spectrum.sci` — plus this README.
