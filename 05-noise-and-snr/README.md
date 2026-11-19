# 05 — Noise, AWGN and SNR (Experiment 5)

## Objective
Understand how additive white Gaussian noise (AWGN) corrupts AM and FM signals, learn the standard SNR convention (signal power from mean-square, dB from a ratio), generate noise at a chosen target SNR, and quantify how demodulation quality degrades as SNR falls.

## Theory

**AWGN definition.** AWGN is the standard noise model for communication links. "Gaussian" means the noise amplitude at any instant follows a normal (Gaussian) distribution with mean 0 and variance sigma^2, i.e. n ~ N(0, sigma^2). "White" means the power spectral density is FLAT over the band of interest — equal power at every frequency — and successive samples are independent (uncorrelated). It is "additive" because the received signal is y(t) = s(t) + n(t).

**Signal power.** For a discrete-time signal s, the average (mean-square) power is

    Ps = mean(s.^2)

For a sinusoid of amplitude Ac, Ps = Ac^2 / 2.

**SNR and dB.** With noise n, noise power Pn = mean(n.^2), then

    SNR_linear = Ps / Pn
    SNR_dB     = 10 * log10(Ps / Pn)

Do not confuse this with 20*log10(Vratio) — power ratios use 10*log10.

**Noise from a target SNR.** Given desired SNR_dB, solve for the required noise variance:

    sigma^2 = Ps / 10^(SNR_dB/10)
    sigma   = sqrt(Ps * 10^(-SNR_dB/10))

then generate n = grand(1, N, "nor", 0, sigma). Always use `rand("seed", 123)` first for reproducibility. Never use `rand()` (uniform) for AWGN.

**Noise power and bandwidth.** Real thermal noise has a one-sided noise spectral density N0/2 (W/Hz). For a receiver of bandwidth B, the noise power in band is Pn = N0 * B. Doubling the bandwidth doubles the in-band noise power and halves the SNR — this is why bandwidth is not free. AWGN in simulation models the in-band portion directly via sigma.

**Why FM resists amplitude noise.** An FM signal is constant-envelope: all information lives in the instantaneous frequency, not in the amplitude. An FM receiver uses a LIMITER that clips off any amplitude variations (including noise ripple) before the discriminator/demodulator. Noise therefore cannot modulate the recovered baseband as long as the signal stays above the noise and the limiter does not clip the carrier itself (capture effect: the stronger of two co-channel signals suppresses the weaker one). AM envelope detection, by contrast, measures amplitude directly, so noise rides straight into the recovered message.

## Parameter meanings
- `fs = 10000` Hz — sampling frequency (fs >> fc = 200 Hz satisfies Nyquist).
- `fm = 10` Hz — message (modulating) frequency; message Am = 1 V, m(t) = Am*cos(2*pi*fm*t).
- `fc = 200` Hz — carrier frequency for both AM and FM.
- `Ac = 1` V — carrier amplitude.
- `mu = 0.5` — AM modulation index (0 < mu < 1: no over-modulation, envelope detector valid).
- `beta = 2`, `kf = 20` Hz/V — FM modulation index and frequency sensitivity (beta = kf*Am/fm = 20/10 = 2). Frequency deviation df = beta*fm = 20 Hz.
- `Tdur = 0.5` s, t = 0:1/fs:0.5-1/fs — time vector, 5000 samples; FFT N = 5000.
- `sigma` — noise std dev; noise variance sigma^2 sets noise power.
- `SNR_dB` — target signal-to-noise ratio in decibels.

**SNR convention (used everywhere in this experiment):**

    Ps = mean(s.^2);  Pn = mean(n.^2);
    SNR_dB = 10*log10(Ps/Pn);
    given target SNR_dB: sigma^2 = Ps / 10^(SNR_dB/10)

## How to run
From a fresh terminal (Scilab 2024.1):

    cd /home/abhishek/scilab-communications-lab/05-noise-and-snr
    scilab -nw -nb -e "exec('awgn-generation.sci', -1)"

Or open any .sci in the Scilab GUI editor and run it (F5). Each script is self-contained, seeds its RNG (`rand("seed", 123)`), pops figure windows (scf/clf) and prints KEY RESULTS via disp()/mprintf. No internet, no toolboxes, no absolute paths.

## Expected plots and interpretation

1. **awgn-generation.sci** — Figure 1: top = noise waveform (zero-mean fuzz, amplitude mostly within +/-3 sigma); bottom = 50-bin histogram overlaid with the theoretical N(0,1) pdf scaled to counts. Measured mean ~0.009, variance ~1.014 (finite-sample spread around the theory, expected). Key idea: white noise = flat PSD, independent samples.
2. **noisy-am-signal.sci** — 3 subplots (first 0.2 s): clean AM (visible carrier under envelope), AWGN, noisy AM. Ps = 0.5625, Pn ~0.057, measured SNR ~9.94 dB. The AM envelope is still tracking the 10 Hz message; an envelope detector would recover a noisy but recognizable m(t).
3. **noisy-fm-signal.sci** — 3 subplots (first 0.2 s): clean FM (constant amplitude, varying zero-crossing rate), AWGN, noisy FM. Ps = 0.5, measured SNR ~9.94 dB. Noise visibly perturbs the peak amplitudes, but an FM limiter ignores amplitude, so the phase/frequency content survives far better than AM at equal SNR.
4. **snr-calculation.sci** — prints TARGET vs MEASURED SNR for 20/10/5/0 dB (measured: ~19.94, ~9.88, ~4.90, ~0.02 dB; small deltas from only 5000 samples) and plots the four noisy signals in stacked subplots. Shows the variance formula sigma^2 = Ps/10^(SNR/10) does its job.
5. **snr-comparison.sci** — Figure 1: original message + envelope-detected recovered message at SNR = 20, 10, 0, -5 dB. Figure 2: bar chart of correlation(recovered, original) vs SNR. Printed correlations: 0.960 (20 dB), 0.952 (10 dB), 0.800 (0 dB), 0.448 (-5 dB). Degradation is graceful but steady — correlation drops as noise grows.

## Observations
- Fixing `rand("seed", 123)` makes every run bit-identical; comparisons between students or machines become meaningful.
- Measured SNR never equals target exactly with finite samples — over 5000 samples expect |delta| < ~0.2 dB.
- AM power Ps = 0.5625 (not Ac^2/2 = 0.5) because the DC term Ac^2/2 = 0.5 plus the message-sideband power mu^2*Am^2*Ac^2/4 = 0.0625 adds up: 0.5 + 0.0625 = 0.5625. FM, being a pure sinusoid envelope, has Ps = Ac^2/2 = 0.5.
- Envelope detection quality depends on mu < 1 and on fc >> fm so the moving average (L = fs/fc = 50) removes carrier ripple without touching the message.
- FM's practical advantage appears only AFTER a limiter; raw noisy FM peaks are just as corrupted as raw noisy AM.

## Common mistakes
- Using `rand()` (uniform distribution) instead of `grand(m,n,"nor",mu,sigma)` — uniform noise has the wrong amplitude distribution and the wrong peak statistics.
- Forgetting to normalize noise to the target SNR (adding unit-variance noise regardless of Ps) — the SNR then depends on accidental amplitudes.
- Comparing powers without dB, or reading `10*log10(V)` where `20*log10(V)` was implied — power uses 10*log10.
- Using peak amplitude instead of mean-square (mean(s.^2)) as "power".
- Not fixing the random seed — every run gives different numbers and nothing is reproducible.
- Over-modulating AM (mu >= 1) and then wondering why the envelope is distorted or the envelope detector inverts peaks.
- Writing cos(2*pi*(fc+kf*m)*t) for FM instead of phase-integrating (cumsum method) — not constant-envelope, wrong spectrum.

## Viva questions with answers

**Q1. What does "white" mean in AWGN?**
Flat PSD over the band of interest — every frequency component carries equal average power, and successive time samples are independent (autocorrelation is a delta at zero lag).

**Q2. What is the pdf of AWGN samples?**
A zero-mean Gaussian: p(n) = (1/(sigma*sqrt(2*pi))) * exp(-n^2 / (2*sigma^2)), i.e. n ~ N(0, sigma^2).

**Q3. Write the SNR convention used in this lab.**
Ps = mean(s.^2); Pn = mean(n.^2); SNR_dB = 10*log10(Ps/Pn).

**Q4. Given target SNR_dB, how do you pick the noise variance?**
sigma^2 = Ps / 10^(SNR_dB/10), i.e. sigma = sqrt(Ps * 10^(-SNR_dB/10)).

**Q5. Why is 10*log10 used and not 20*log10?**
SNR here is a ratio of POWERS; power in dB uses 10*log10. 20*log10 applies to amplitude (voltage) ratios.

**Q6. Why does doubling bandwidth halve the SNR (thermal noise)?**
Noise power in band is Pn = N0*B. Larger B admits more noise power for the same signal power, so SNR falls linearly in B.

**Q7. Why is FM more robust to amplitude noise than AM?**
FM carries information in instantaneous frequency; a limiter strips amplitude variations before demodulation, so amplitude noise never reaches the baseband (provided the carrier stays above noise / capture effect). AM's envelope detector responds directly to amplitude, noise included.

**Q8. What is the capture effect?**
In FM, when two co-channel signals arrive, the stronger one suppresses the weaker almost entirely at the discriminator output, rather than both being heard (as in AM).

**Q9. What does the envelope detector in snr-comparison.sci compute?**
abs(y) (rectifier) followed by a moving average of length L = round(fs/fc) = 50, which low-passes and tracks the 10 Hz envelope Ac*(1+mu*m(t)) while rejecting the 2*fc ripple.

**Q10. Why does the recovered message need DC removal before correlation?**
The rectified-then-averaged envelope has a large DC term (~Ac plus a noise rectification bias). Correlation of uncentered signals would be dominated by that constant; subtracting each mean isolates the message-bearing component.

**Q11. Why don't measured SNRs equal targets exactly?**
Finite samples: with 5000 noise samples the sample variance fluctuates (chi-square spread), so Pn and hence the measured SNR differ from the theoretical value by a fraction of a dB.

**Q12. Why is rand() wrong for AWGN and which function is right?**
rand() produces uniformly distributed samples with mean 0.5 and variance 1/12, wrong distribution and wrong tails. Use grand(m,n,"nor",mu,sigma), Scilab's built-in Gaussian generator — e.g. grand(1, N, "nor", 0, sigma).
