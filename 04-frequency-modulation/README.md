# 04 — Frequency Modulation (Experiment 4: FM Transmission and Reception)

## Objective

Generate, analyse and demodulate a frequency-modulated (FM) signal in Scilab. Specifically: construct FM with the correct phase-integration method, observe how the instantaneous frequency swings around the carrier, measure the modulation index from the frequency deviation, compare narrowband and wideband FM spectra (Bessel sidebands, Carson's rule), and recover the message with a differentiator + envelope detector.

## Theory

- FM equation (tone modulation): `s(t) = Ac * cos(wc*t + beta*sin(wm*t))` for `m(t) = Am*sin(wm*t)`, with `wc = 2*pi*fc`, `wm = 2*pi*fm`.
- Instantaneous frequency: `f_i(t) = fc + kf*m(t)` — the carrier frequency deviates around fc in step with the message.
- Frequency deviation: `df = kf*Am` (units Hz). Modulation index: `beta = df/fm` (dimensionless, peak phase deviation in radians).
- kf is the **frequency sensitivity** of the modulator, units **Hz/volt** — how many Hz of carrier shift you get per volt of message.
- FM is constant-envelope: the information lives in the *rate of zero crossings*, never in the amplitude.
- Phase-integration (the only correct numerical way to build FM):
  `s(t) = Ac*cos(2*pi*fc*t + 2*pi*kf*integral(m(tau))dtau)`.
  Numerically the integral is `cumsum(m)/fs`.
- Sidebands are weighted by Bessel functions `J_n(beta)`:
  `s(t) = Ac*sum_ over_n J_n(beta)*cos((wc + n*wm)*t)` (for sine-tone modulation).
  Sidebands appear in pairs at `fc +/- n*fm`, spacing = fm.
- Carson's rule: transmission bandwidth `BW = 2*(beta + 1)*fm`.
- Narrowband FM: `beta << 1` (e.g. 0.2) — approximately a carrier plus two sidebands, `BW ~ 2*fm`, very similar to AM.
- Wideband FM: `beta >= 1` (here beta = 5) — many significant sideband pairs (~ beta + 1), and the carrier power falls as `J_0(beta)^2` (for beta = 5, J_0(5) ~ -0.178, so the carrier is almost gone).
- FM vs AM: in AM the message rides on the amplitude (envelope detection works; amplitude carries information, so noise riding on amplitude is indistinguishable). In FM the amplitude is constant, so amplitude noise can be clipped off at the receiver — this is why FM sounds cleaner. The cost is bandwidth and a more complex receiver.
- Demodulation by differentiation + envelope: differentiate s(t) so the message multiplies the (differentiated) sinusoid as an amplitude term, `d/dt s = -Ac*phi'(t)*sin(phi(t))` with `phi' = 2*pi*(fc + kf*m(t))`; rectify (`abs`); low-pass (moving average); subtract the DC offset (the fc term); what remains is proportional to `m(t)`.

## Parameter meanings

| Symbol | Meaning | Value in these demos |
|--------|---------|---------------------|
| fs | Sampling frequency | 10000 Hz |
| fm | Message frequency | 10 Hz |
| fc | Carrier frequency | 200 Hz |
| Ac | Carrier (constant) amplitude | 1 V |
| Am | Message amplitude | 1 V |
| kf | Frequency sensitivity | Hz/V, chosen per demo (10, 2, 50, 20, 30) |
| df | Frequency deviation `kf*Am` | beta*fm |
| beta | Modulation index `df/fm` | 0.2 (NBFM) ... 5 (wideband) |
| L | Moving-average length for the demodulator LP | 100 samples (first null at fs/L = 100 Hz) |

All time plots use Tdur = 0.4 s (4 message cycles). The FFT bin spacing is 1/Tdur = 2.5 Hz, so spectral lines at fc +/- n*fm land exactly on bins.

## Block diagram

```
 Message m(t)                Phase modulator            Carrier
 Am*cos(2*pi*fm*t) ──► Integrator ──► phase ──► s(t) ──► s(t) = Ac*cos(phi(t))
                     (cumsum/fs)     summer     fc*2*pi*t

 Reception:
 s(t) ──► Differentiator ──► Envelope detector ──► subtract DC ──► m̂(t)
          (diff)             (abs + moving avg     (mean removal)
                              L = 100 samples)
```

## How to run

```bash
cd /home/abhishek/scilab-communications-lab/04-frequency-modulation
scilab -nw -nb -e "exec('fm-generation.sci', -1)"
```

Or open the file in the Scilab editor and press Execute (F5). Every file is self-contained, uses only Scilab 2024.1 syntax, and prints its key numbers with `disp`/`mprintf`.

## Expected plots and interpretation (each file)

**fm-generation.sci** — 3 subplots: (1) the message; (2) the instantaneous frequency f_i(t) = fc + kf*m(t) — a cosine swinging between 190 and 210 Hz; (3) the FM signal with constant amplitude but non-uniform zero-crossing spacing. Key numbers: df = 10 Hz, beta = 1, kf = 10 Hz/V.

**fm-modulation-index.sci** — Message and instantaneous frequency for beta = 3 (kf = 30 Hz/V). beta is computed twice — from parameters (df/fm = 3) and from the measured swing ((fi_max - fc)/fm = (230 - 200)/10 = 3). They agree to machine precision.

**narrowband-fm.sci** — FFT magnitude around fc for beta = 0.2 (kf = 2 Hz/V) vs conventional AM with mu = 0.2. Both show a strong carrier plus two tiny sidebands at fc +/- fm. Measured NBFM first sideband ≈ 0.0995 V vs the theoretical Ac*beta/2 = 0.1 V. Conclusion: NBFM looks and behaves like AM, and its bandwidth ≈ 2*fm.

**wideband-fm.sci** — (1) FM time signal for beta = 5, (2) instantaneous frequency swinging 150..250 Hz, (3) full FFT 0..fs/2 with clear Bessel sideband pairs at fc +/- n*10 Hz. The measured largest peaks (240, 160, 170, 230, 190, 210 Hz — the n = 4, 4, 3, 3, 1, 1 pairs) match J_4(5) = 0.391, J_3(5) = 0.365, J_1(5) = 0.328. Carson BW = 120 Hz.

**fm-demodulation.sci** — The chain diff → abs → moving average (L = 100) → subtract mean. Panel 3 overlays the recovered (normalized) message shape on m(t). Correlation coefficient ≈ 0.93 (> 0.9 as required; the start-up transient of the FIR filter is excluded from the correlation window). The large DC term in panel 2 is the fc contribution; the ripple around it is proportional to kf*m(t).

**fm-frequency-spectrum.sci** — Two spectra on a shared frequency axis: beta = 5 (many sideband pairs out to n ≈ 6-7) and beta = 0.5 (carrier + one weak pair). Disps peak bins for both and the rule: number of significant sideband pairs ≈ beta + 1.

## Observations

- The amplitude of an FM signal is constant; the message is encoded in the instantaneous frequency, so `abs(s)` alone carries no message — you must differentiate first.
- The FM spectrum is symmetric about fc and spaced by fm; carrier height follows |J_0(beta)|.
- Carson's rule BW = 2*(beta+1)*fm matches the visible sideband spread (beta = 5 → 120 Hz occupied, lines 140..260 Hz).
- beta can be read directly off a spectrum (count significant pairs) or off a frequency plot ((fi_max - fc)/fm) — both agree.
- NBFM and AM spectra are nearly identical for small beta; wideband FM is unmistakably different (many pairs, carrier suppressed).
- The demodulator's DC subtraction is essential — the fc term is usually much larger than the message-induced swing.

## Common mistakes

1. **Treating FM as AM** — varying the amplitude of the carrier instead of its frequency. FM must have constant |s(t)| = Ac.
2. **Forgetting the phase integration / cumsum** — writing `cos(2*pi*(fc + kf*m)*t)` is not FM; the phase must be the *time integral* of the instantaneous frequency. Use `2*%pi*fc*t + 2*%pi*kf*cumsum(m)/fs`.
3. **Wrong units of kf** — kf is in Hz/V, not V/Hz and not dimensionless. df = kf*Am must come out in Hz.
4. **Envelope detection BEFORE differentiation** — `abs(s)` is just a constant for a constant-envelope signal; it contains no message. Differentiate first, then rectify, then low-pass.
5. **FFT axis / scaling errors** — forget the 2/N single-sided scaling (double everything except DC and Nyquist), and remember the bin spacing is fs/N = 1/Tdur (2.5 Hz here), so sidebands at fc +/- n*10 Hz land exactly on bins.
6. **Comparing spectra on different amplitude scales** — NBFM and wideband spectra differ enormously in sideband heights; always compare shape with the same 2/N normalization.
7. **Moving-average too long** — L must pass fm = 10 Hz but reject ripple near 2*fc = 400 Hz. L = 100 (first null at fs/L = 100 Hz) satisfies both; L = 1000 would blur the message badly.
8. **Ignoring filter group delay** — the causal moving average delays the output by (L-1)/2 samples; compensate before overlaying or computing correlation.
9. **Including the FIR start-up transient in correlation** — the first ~L samples are not steady-state; excluding them raises the correlation from ~0.81 to ~0.93.
10. **Expecting amplitude information to survive limiting** — FM receivers usually include a hard limiter before the discriminator; any amplitude noise picked up in the channel is removed there.

## Comparison FM vs AM table

| Property | AM (conventional) | FM |
|---|---|---|
| Message encoded in | Amplitude (envelope) | Instantaneous frequency / phase |
| Envelope | Carries information, must be >= 0 for envelope detection | Constant = Ac |
| Spectrum | Carrier ± 2 sidebands, spacing fm | Carrier ± n pairs, spacing fm, Bessel-weighted J_n(beta) |
| Bandwidth | 2*fm | 2*(beta+1)*fm (Carson) |
| Sideband amplitude | mu*Ac/2 | J_n(beta)*Ac |
| Noise robustness | Poor (noise rides on amplitude) | Good (limiter removes amplitude noise); worth beta in exchange for bandwidth |
| Demodulation | Envelope detector or synchronous | Differentiator + envelope, or PLL/discriminator |
| Power efficiency | Carrier wastes power | Carrier power can fall as J_0(beta)^2 (beta = 5 nearly null) |
| Complexity | Simple | More complex modulator/demodulator |
| Typical use | AM broadcast, simple links | FM broadcast, mobile, microwave links |

## Viva questions with answers

1. **Write the FM signal for a sinusoidal message.** s(t) = Ac*cos(wc*t + beta*sin(wm*t)), beta = df/fm, df = kf*Am.
2. **What is instantaneous frequency and how is it defined?** f_i(t) = (1/2*pi) * d(phi(t))/dt = fc + kf*m(t); it is the frequency the carrier has at that instant.
3. **Define modulation index beta for FM. What are its units?** beta = df/fm = peak phase deviation in radians; dimensionless.
4. **What does kf mean and what are its units?** The frequency sensitivity of the modulator — Hz shift produced per volt of message; Hz/V.
5. **Why is cumsum used to generate FM in Scilab?** FM is defined by integrating the instantaneous frequency to obtain phase; cumsum(m)/fs is the discrete-time integral. Without it you do not get Bessel sidebands.
6. **What are the sideband amplitudes in wideband FM?** Ac*|J_n(beta)| for the pair at fc +/- n*fm; for beta = 5 the strongest pairs are n = 4, 3, 1 (J_4 = 0.391, J_3 = 0.365, J_1 = 0.328).
7. **State Carson's rule and apply it to beta = 5, fm = 10 Hz.** BW ≈ 2*(beta+1)*fm = 2*6*10 = 120 Hz.
8. **How many significant sideband pairs does beta = 5 produce?** About beta + 1 ≈ 6 pairs (n = 0..6); J_n(5) is negligible beyond n ≈ 8.
9. **NBFM vs wideband FM — definitions and spectra?** NBFM: beta << 1; spectrum ≈ carrier + 2 sidebands, BW ≈ 2*fm, like AM. Wideband: beta >= 1; many pairs, wide BW, carrier suppressed.
10. **Why does envelope detection of s(t) fail for FM, and how do we fix it?** The envelope is constant; rectifying gives a DC level. Differentiate first so the message appears as an amplitude modulation of the derivative, then rectify and low-pass.
11. **Why is FM more noise-robust than AM?** Noise mostly adds in amplitude; an FM limiter strips amplitude variations before the discriminator, so amplitude noise does not reach the audio. AM has no such luxury.
12. **You measure fi_max = 230 Hz and fi_min = 170 Hz for fc = 200 Hz, fm = 10 Hz. Find beta.** Peak swing = (230 - 200)/10 = 3 = (fc - 170)/10; beta = swing/fm = 3. (Peak-to-peak = 60 Hz = 2*df.)
