# 06 — Pulse Modulation (Experiment 6)

Pulse modulation — construction of PAM/PWM/PPM waveforms from a message signal.

Reader: undergraduate ECE student, Linux, Scilab 2024.1.

## Objective

To understand how a continuous message signal m(t) is converted into a
sequence of pulses whose **amplitude** (PAM), **width** (PWM) or **position**
(PPM) carries the information; to build each waveform sample by sample from a
high-resolution analysis grid; and to demodulate it back to an estimate of
m(t) with a lowpass filter or by direct measurement. This experiment is the
bridge between analog modulation (Experiments 3–5) and digital pulse-code
transmission (Experiment 7 — PCM).

## Theory

All three schemes start from the same idea — **sample** m(t) at a pulse
repetition rate fs_s, then let one property of every pulse carry the sample.

- **PAM (Pulse Amplitude Modulation)** — a sequence of narrow pulses whose
  *amplitude* equals the message sample value. It is the pulse analogue of
  PAM = "sampled pulses": the information lives in pulse height.
  - *Natural sampling:* the top of each pulse follows m(t) exactly (a slice
    of the message). Spectrum = replicas of M(f) under a sinc envelope; **no
    aperture distortion**.
  - *Flat-top (sample-and-hold):* every pulse is held flat at m(t_s(k)).
    Equivalent to convolving the impulse-sampled message with a rectangular
    pulse → the spectrum is multiplied by **sinc(f·tau)**, an *aperture
    (droop) distortion* that must be equalized at the receiver. For
    fm·tau << 1 the effect is negligible.
  - *Ideal/instantaneous:* pulse height = instantaneous sample; our
    pam-generation.sci uses a practical narrow version of this.
- **PWM (Pulse Width Modulation)** — pulse *width* varies with the message
  amplitude while amplitude stays constant: tau_k = tau0·(1 + m_mod·m(k)/max|m|).
  Proportional-to-amplitude width, constant amplitude. Often called pulse
  duration modulation (PDM).
- **PPM (Pulse Position Modulation)** — pulse *position* varies with the
  message amplitude while width and amplitude stay constant:
  d_k = D·m(k)/max|m|. Position-proportional-to-amplitude.
- **Demodulation by LP** — for PAM: feed the waveform into a lowpass filter
  (cutoff between fm and fs_s − fm) to strip the pulse-rate replicas. For PWM:
  the LP output equals the duty cycle, i.e. ∝ m plus a DC offset that must be
  removed. For PPM: a plain LP does not work directly — the message is in the
  edges — so a PPM detector times the rising edges and inverts the position
  law (an LP can then smooth the resulting stair).
- **Comparison table**

  | Property              | PAM                     | PWM                        | PPM                        |
  |-----------------------|-------------------------|----------------------------|----------------------------|
  | Parameter varied      | amplitude               | width                      | position                   |
  | Constant              | width, repetition rate  | amplitude, repetition rate | width, amplitude           |
  | Power (per pulse)     | highest (full pulse)    | medium                     | lowest (very short pulses) |
  | Noise immunity        | worst (amplitude noise) | good (timing info)         | best (edge-timing only)    |
  | Bandwidth             | ~ 1/(2·tau) (largest)   | ~ 1/(2·tau_min)            | ~ 1/(2·tau_p) (widest BW per Hz… but least power) |
  | Linearity             | linear in m             | linear in m (pre-LP)       | linear in m (edge law)     |
  | Demodulation          | simple LP               | LP (duty → m)              | edge detector + law inversion |

  *(Bandwidths: PPM needs the sharpest edges, so its spectral occupancy per
  pulse rate is the largest; PAM is spectrally most economical in power use.)*

- **fs_s = pulse repetition frequency (PRF)** — the pulse repetition rate IS
  the sampling rate. The **duty cycle** = tau/Ts (PAM/PWM) or tau_p/Ts (PPM):
  PAM 25%, PWM variable 8–72% of Ts, PPM 5%. Duty cycle sets average power and
  how easily an LP can recover the message.

## Sampling frequency relation (Experiment 7 bridge)

Here the pulse repetition rate equals the sampling rate: fs_s = 50 Hz = 1/Ts,
with Ts = 0.02 s between successive samples of the 5 Hz message. In Experiment
7 (PCM) the same statement becomes: raising fs_s (more samples per message
cycle) improves reconstruction fidelity and reduces aliasing/quantization
noise, but every sample must be encoded and transmitted, so bandwidth grows
linearly with fs_s. The pulse repetition frequency of a PAM/PWM/PPM stream is
exactly the sampling frequency a PCM system would use; pulse *width* (tau)
only sets the spectral spread/occupancy, not the sampling rate. Rule of thumb:
fs_s ≥ 2·fm (Nyquist) is the theoretical floor; practical systems use
fs_s ≥ 8–10×fm. Here fs_s = 10·fm = 50 Hz.

## Parameter meanings

| Symbol | Value         | Meaning                                            |
|--------|---------------|----------------------------------------------------|
| fs     | 20000 Hz      | high-res analysis grid (time axis t = 0:1/fs:0.1−1/fs, 2000 points) |
| Tdur   | 0.1 s         | analysis window (half a message cycle)             |
| fm     | 5 Hz          | message frequency, m(t) = sin(2π·5·t), amplitude 1 V |
| fs_s   | 50 Hz         | pulse repetition rate = sampling rate              |
| Ts     | 0.02 s        | sampling period (1/fs_s)                           |
| tau    | 0.005 s       | PAM pulse width (25% duty cycle of Ts)             |
| tau0   | 0.008 s       | PWM mid (unmodulated) width                        |
| m_mod  | 0.8           | PWM modulation depth (80%)                         |
| tau_p  | 0.001 s       | PPM fixed pulse width                              |
| D      | 0.008 s       | PPM max position deviation (< Ts − tau_p)          |
| A      | 1 V           | PWM/PPM constant pulse amplitude                   |
| L      | 400           | moving-average LP length = fs/fs_s = 1 Ts          |
| t_s    | 0:Ts:max(t)   | sampling instants → 5 samples per window           |

## How to run

```sh
cd /home/abhishek/scilab-communications-lab/06-pulse-modulation
scilab -nw -nb -e "exec('pam-generation.sci', -1)"
# or for an interactive session with plots:
scilab -nb
```

Every script is self-contained (rebuilds its own PAM/PWM/PPM waveform from the
message), so files can be run in any order. Each script ends with `disp()` of
key numbers. Smoke-test command used for all files:

```sh
cd /home/abhishek/scilab-communications-lab/06-pulse-modulation && timeout 120 scilab -nw -nb -e "exec('FILE.sci', -1)"
```

## Expected plots and interpretation (each file)

- **pam-generation.sci** — subplot 1: m(t) with red markers at the sampling
  instants (0, 0.02, …, 0.08); subplot 2: PAM waveform — narrow flat pulses of
  height = instantaneous sample value. 5 pulses, duty 25%. Teaches: PAM =
  "sample and gate".
- **pam-natural.sci** — subplot 1: m(t) + sample markers; subplot 2: natural
  PAM (red, pulse tops follow m(t)) overlaid on flat-top PAM (green dashed).
  Measured peak |natural − flat-top| = 0.155 V. Teaches: natural sampling has
  NO aperture distortion; flat-top does.
- **pam-flat-top.sci** — same layout; flat-top pulses frozen at the value
  measured at pulse start. Aperture droop across the first pulse = 0.155 V;
  sinc(fm·tau) = 0.9995 → negligible here, but grows with tau and fm.
- **pam-demodulation.sci** — subplot 1: original vs sinc-interpolated
  reconstruction (interior error ~3e-16 V — machine precision; large at window
  edges because samples outside the window are missing); subplot 2: original vs
  centered moving-average LP output (L = 400), correlation ≈ 0.94.
- **pwm-generation.sci** — subplot 1: m(t) + markers; subplot 2: PWM waveform,
  constant amplitude 1 V, widths 0.008 → 0.0141 s tracking the (all-positive)
  half-sine message. Teaches: width carries the info; amplitude must not.
- **pwm-demodulation.sci** — subplot 1: the PWM waveform itself; subplot 2:
  original vs LP-recovered (green dashed, correlation ≈ 0.64) and vs the exact
  per-period pulse-area inverse (magenta dots, correlation ≈ 0.999997,
  per-sample error ≈ 0.006 V). Teaches: LP on PWM yields duty cycle ∝ m + DC;
  subtract the mean before using it.
- **ppm-generation.sci** — subplot 1: m(t) + markers; subplot 2: PPM waveform —
  every pulse identical (1 ms wide, 1 V tall), only position shifts. Position
  range measured [0, 0.0076] s.
- **ppm-demodulation.sci** — subplot 1: original vs stair (nearest-sample
  hold) PPM estimate (max error ≈ 1.06e-3 V — limited by 50 µs edge
  quantization); subplot 2: LP-smoothed estimate (MA over 3 Ts), correlation
  ≈ 0.86. Teaches: PPM receivers need only a comparator and a counter.

## Observations

- Only 5 samples fall in the 0.1 s window (t_s = 0 … 0.08 s) — half a message
  cycle, yet enough to convey the 5 Hz bump unambiguously because fs_s = 10·fm.
- The message over 0–0.1 s is a positive half-sine (max|m| = 1 at t = 0.05 s),
  so all PWM widths and PPM delays are non-negative; bipolar modulation would
  produce early pulses for negative m.
- Ideal sinc reconstruction is machine-precision inside the sampled region —
  proof that the Nyquist criterion is met; edge error is a truncation effect,
  not aliasing.
- A moving average of length Ts (L = 400 = fs/fs_s) places a notch exactly at
  the 50 Hz pulse rate — measured PAM correlation improved from 0.50 (L = 200)
  to 0.94 (L = 400).
- PWM LP correlation is limited by ripple/sag trade-off; the pulse-area
  integrator recovers m essentially exactly (corr ≈ 0.9999971), showing the LP
  is a convenience, not a necessity, for PWM.
- PPM edge quantization error is ≤ 1/fs = 50 µs of delay → ≤ 50e-6/0.008 × 1 V
  ≈ 0.6% of peak; measured per-sample error is 1.06e-3 V.
- Flat-top vs natural PAM differ only inside the pulse windows; the peak
  deviation equals the message slew over tau = 5·tau·cos(…) ≈ 0.155 V here.

## Common mistakes

- **PPM pulses overlapping when the delay is too big** — you must guarantee
  max|d_k| + tau_p < Ts. Here 0.008 + 0.001 = 0.009 s < 0.02 s. If you raise D
  above Ts − tau_p = 0.019 s, pulses drift into the next period and the edge
  detector locks onto the wrong pulse.
- **PWM amplitude accidentally varying** — e.g. writing y(i) = ms instead of a
  constant A; then it is PAM, not PWM, and the "width" information is buried.
- **Flat-top confused with natural** — flat-top holds m at the *start* of the
  pulse (droop across tau); natural keeps m(t(i)) *inside* the pulse. The two
  differ by up to 0.155 V here.
- **LP order too low / too high** — too low (tiny L, e.g. 20) lets 50 Hz ripple
  through (PWM corr ≈ 0.19 at L = 100); too high (L >> Ts) smears the 5 Hz
  message (sag) and destroys the edges the PPM detector needs. L = fs/fs_s =
  1 Ts is the sweet spot.
- **fs too low and pulse edges blur** — the analysis grid must be ≳ 10× the
  pulse bandwidth: fs = 20000 Hz resolves tau = 1 ms pulses by 20 samples and
  the 1/fs = 50 µs edge quantization limits PPM accuracy. At fs = 2000 Hz,
  tau_p = 0.001 s is only 2 samples — reconstruction is meaningless.
- **Sampling marker/index misalignment** — t_s(k) must lie exactly on the
  grid: use i = round(t_s(k)*fs)+1, never find(t == t_s(k)).
- **Judging PAM reconstruction quality over the whole window** — sinc error is
  dominated by truncation at the edges; compute max error on the interior and
  say so.
- **Forgetting the duty-cycle normalization (Ts/tau)** for the PAM LP path —
  the raw MA output peaks at 0.25, not 1.

## Viva questions with answers

**Q1. Why is PAM called the first step of PCM?**
A. PCM = sampling + quantization + encoding. PAM performs the sampling (and
holds the samples as amplitudes); PCM then quantizes those amplitudes and
codes them as bits (Experiment 7).

**Q2. What is the difference between natural and flat-top sampling?**
A. Natural: pulse tops follow m(t) — no aperture distortion. Flat-top: pulses
hold m(t_s) constant — adds sinc(f·tau) roll-off (aperture effect) needing an
equalizer.

**Q3. Why does flat-top sampling cause aperture distortion?**
A. Holding a value for duration tau = convolving with rect(t/tau) →
multiplication by sinc(f·tau) in frequency. High frequencies are attenuated;
needs correction if fm·tau is not << 1.

**Q4. State the Nyquist rate for this message. Can fs_s = 50 Hz work?**
A. fs_Nyquist = 2·fm = 10 Hz; fs_s = 50 Hz >> 10 Hz — yes, 10 samples/cycle.
Edge case: fs_s = 10 Hz would put samples at zero crossings only (aliasing of
phase); aliasing appears below 10 Hz.

**Q5. What carries information in PAM, PWM and PPM?**
A. Amplitude / width / position respectively. In PWM and PPM the amplitude is
a constant A and carries no information.

**Q6. Why is PWM better than PAM in noise?**
A. Information is in a timing quantity with a constant amplitude; receiver can
hard-limit and measure widths. Amplitude noise (which corrupts PAM) barely
affects width measurement if SNR is above threshold.

**Q7. Why is PPM the most power-efficient?**
A. Pulses are very short (tau_p = 1 ms, 5% duty); average power = A²·tau_p/Ts
≪ PWM/PAM. Same information in far fewer joules per sample.

**Q8. Why can't a simple LP demodulate PPM?**
A. All pulses are identical in height and width; LP sees only a DC + ripple.
The message is encoded in edge times — you must measure delays (edge
detection), then invert d = D·m/max|m|.

**Q9. What sets the bandwidth of a pulse-modulated signal?**
A. The pulse edge rate and rise time (≈ 1/tau), not the message. PAM tau =
5 ms → BW ~ 200 Hz; PPM tau_p = 1 ms → BW ~ 1 kHz. Narrow pulses → wide
spectrum.

**Q10. What is the duty cycle here for each scheme?**
A. PAM: tau/Ts = 0.25 (25%). PWM: tau_k/Ts, modulated 8–72% (tau0 = 8 ms →
40% at m = 0). PPM: tau_p/Ts = 0.05 (5%).

**Q11. Why must the demodulated PWM signal have its mean subtracted?**
A. Duty = tau0/Ts·(1 + m_mod·m/max|m|) → the output contains DC =
A·tau0/Ts. Subtracting the mean leaves only the term proportional to m.

**Q12. How does raising fs_s affect the reconstruction and the bandwidth?**
A. Higher fs_s → more samples per message cycle → better reconstruction and
larger aliasing margin; pulse repetition frequency rises → occupied bandwidth
and transmission rate rise proportionally. That is exactly the trade PCM makes
in Experiment 7 (more bits/second, better fidelity).
