# 01 — Signal Generation

## Objective

Learn how to generate the basic building-block signals of communication
systems in Scilab 2024.1 on Linux: sine, cosine, composite (multi-harmonic)
signals, square, triangular and sawtooth waves, and the three fundamental
signal operations — addition (superposition), subtraction and multiplication
(a preview of modulation). By the end of this experiment you can create,
plot, measure and combine any of these waveforms.

## Theory

**Sine and cosine.** The pure tone is the foundation of all communication:

```
sine(t)    = A * sin(2*pi*f*t + phi)
cosine(t)  = A * cos(2*pi*f*t + phi)
```

A and f define the tone; phi is phase. Cosine leads sine by pi/2 radians:
cos(wt) = sin(wt + pi/2). RMS value of a sine: Arms = A/sqrt(2).

**Harmonics & Fourier series intuition.** Any periodic signal can be built
from sinusoids at the fundamental f and its harmonics 2f, 3f, ... . A square
wave contains only ODD harmonics, with amplitudes falling as 1/n:

```
square(t)  = sum over k=1..inf of (4A/pi) * (1/(2k-1)) * sin(2*pi*(2k-1)*f*t)
```

Keeping only the first 3 terms (1st, 3rd, 5th harmonics) already gives a
recognizable square-ish shape — that is Fourier synthesis in action. A
triangle wave also has only odd harmonics but falls as 1/n^2 (softer edges):

```
triangle(t) = (2/pi) * asin(sin(2*pi*f*t))
```

A sawtooth contains ALL harmonics with amplitudes falling as 1/n:

```
saw(t) = 2 * (f*t mod 1) - 1   (i.e. 2*(f*t - floor(f*t)) - 1)
```

**Composite signals.** Adding sinewaves at f, 2f and 3f produces a periodic
waveform whose shape is set by the relative amplitudes — the starting point
for understanding how a transmitter's spectrum is shaped.

**Signal operations.**
- Addition (superposition): s = s1 + s2 — both frequencies appear in the
  output with unchanged amplitudes. Linear systems behave this way.
- Subtraction: s = s1 - s2 — equals s1 + (-s2); the sign flip is a 180-degree
  (pi radian) phase shift. Basis of differential signaling and interference
  cancellation.
- Multiplication: m(t) * c(t) — creates NEW sum and difference frequencies
  via the identity cos(a)*cos(b) = 0.5*[cos(a-b) + cos(a+b)]. This is the
  heart of Amplitude Modulation (AM): a message at fm multiplied by a carrier
  at fc produces sidebands at fc - fm and fc + fm.

## Parameter meanings

- **A** — amplitude of the signal, in volts (V). Peak value measured from the
  zero axis.
- **f** — (fundamental) frequency, in hertz (Hz). How many cycles per second.
  The period is T = 1/f seconds.
- **fs** — sampling frequency, in samples per second (Hz). To avoid aliasing,
  fs must be more than 2*fmax (Nyquist). All programs here use fs >= 1000 Hz
  (i.e. fs >= 20x the highest frequency of interest), which also keeps the
  plots smooth.
- **t** — time vector, e.g. `t = 0:1/fs:dur`. Each element is one sample time
  in seconds; all signals y(t) are evaluated at these sample instants.
- **dur** — total duration of the time vector, in seconds. Choose it to show
  2-3 periods of the lowest frequency of interest.
- **fm, fc** — message (modulating) and carrier frequencies in the
  multiplication example.
- **phi** — phase shift in radians; 2*pi radians = 360 degrees; pi/2 = 90
  degrees.

## How to run

Open a terminal in this folder and run each program with Scilab in batch
mode (this is also how the files are smoke-tested):

```
cd /home/abhishek/scilab-communications-lab/01-signal-generation
scilab -nw -nb -e "exec('sine-wave.sci', -1)"
```

Replace `sine-wave.sci` with any of the other files. Alternatively, open the
Scilab desktop, use `File -> Open` (or paste the path into the console) and
type `exec('sine-wave.sci', -1)`. Each program opens plot window(s) and
prints key measurements (peak, RMS, average, detected frequencies) to the
console with `disp`/`mprintf`.

## Expected plots and interpretation

- **sine-wave.sci** — one smooth 5 Hz sinusoid, ±2 V, about 3 periods.
  Console shows measured peak ≈ 2 V and RMS ≈ 1.414 V (A/sqrt(2)).
- **cosine-wave.sci** — top plot: cosine, ±2 V. Bottom plot: cosine overlapped
  with a sine shifted left by T/4 (0.05 s) — the two curves coincide,
  proving cos(wt) = sin(wt + pi/2). Console shows phase lead of 1.5708 rad
  (90 deg) and max difference ≈ 0.
- **composite-signal.sci** — 4 stacked subplots: the 5 Hz fundamental
  (1 V), the 10 Hz 2nd harmonic (0.5 V), the 15 Hz 3rd harmonic (0.33 V),
  and the sum. The composite looks like a "bumpy" waveform peaking around
  1.8 V. Console lists component amplitudes/frequencies and names 5 Hz the
  dominant frequency.
- **square-wave.sci** — top: ±1 V square wave switching at 5 Hz. Bottom:
  ideal square vs the 3-harmonic (1st+3rd+5th) Fourier approximation, which
  overshoots slightly at the edges (Gibbs phenomenon) but tracks the ideal
  wave well. Console: fundamental amplitude of the approximation = 4A/pi
  ≈ 1.273 V.
- **triangular-wave.sci** — smooth triangle between -1 V and +1 V, 5 Hz,
  with straight-line edges. Console confirms range [-1, 1] and peak ≈ 1.
- **sawtooth-wave.sci** — ramp from just below -1 up to +1 that drops back
  sharply every 0.2 s (5 Hz). Console shows average ≈ 0.
- **signal-addition.sci** — three stacked plots: 5 Hz (2 V), 100 Hz (0.5 V),
  and their sum (fast ripple riding on a slow wave). Console confirms both
  amplitudes survive addition unchanged.
- **signal-subtraction.sci** — two tones (5 Hz and 15 Hz) and their
  difference. Subtraction is addition of a pi-shifted tone.
- **signal-multiplication.sci** — message (5 Hz), product waveform, and an
  FFT magnitude spectrum x-axis 0-500 Hz. The spectrum shows two lines at
  45 Hz and 55 Hz (fc-fm and fc+fm), each of amplitude 0.5 V — the AM
  sidebands. Console lists the detected peak frequencies.

## Observations

- A sine wave's RMS is A/sqrt(2) — halving the RMS power is why amplifiers
  are rated by A/sqrt(2), not peak.
- Cosine and time-shifted sine are indistinguishable; only phase origin
  differs.
- Truncating a Fourier series leaves ripple (Gibbs phenomenon) near jumps.
- Ideal square/sawtooth waves need infinitely many harmonics; sampling too
  slowly aliases the high harmonics back into the band.
- Addition never creates new frequencies; multiplication always does.
- Multiplication of cos(2*pi*5t) by cos(2*pi*50t) left NO component at 5 or
  50 Hz — only 45 and 55 Hz (0.5 V each).

## Common mistakes

- **Forgetting element-wise operators.** Use `.*`, `./`, `.^` for vector
  operations. Plain `*` is matrix multiplication and errors out (or worse,
  silently does the wrong thing for square arrays).
- **fs too low.** Sampling a 100 Hz signal at fs = 150 Hz aliases it to
  50 Hz. Rule of thumb: fs >= 20x the highest frequency for clean plots and
  fs > 2x fmax for correctness.
- **Only plotting 1 cycle.** One period hides the envelope, harmonics and
  interference beats; always plot at least 2-3 periods.
- **sign() at zero crossings.** `sign(sin(theta))` returns exactly 0 at the
  instants sin(theta) = 0, creating single-sample dips. Harmless for
  visualization, but don't integrate or count zero crossings blindly.
- **Using `clc`, `quit`, `input()`, `pause`, `xs2png`, or absolute paths** —
  these break batch mode (`exec(...)`) and portability. Use `clf()` to clear
  a figure and `scf(n)` to select it.
- **MATLAB-only idioms** such as `~` for not, `&&`/`||` on vectors, or
  `end` indexing without a loop — Scilab uses `<>`, `&`, `|`, and plain
  1-based indexing.
- **Clipping the endpoint of the time vector** inconsistently: use
  `t = 0:1/fs:dur-1/fs` for FFT work (N = fs*dur exactly) and either form
  for plotting.

## Viva questions with answers

**Q1. Why does cos(t) equal sin(t + pi/2)?**
A. sin(wt + pi/2) = sin(wt)cos(pi/2) + cos(wt)sin(pi/2) = cos(wt). A pi/2
(90 degree) phase shift converts sine to cosine.

**Q2. What is the RMS value of a 2 V amplitude sine wave, and why?**
A. Arms = A/sqrt(2) = 2/sqrt(2) ≈ 1.414 V. Squaring sin, averaging over a
period gives 1/2, so the mean-square is A^2/2 and the root mean square is
A/sqrt(2).

**Q3. What does the Fourier series of a square wave contain?**
A. Only odd harmonics (f, 3f, 5f, ...) with amplitudes 4A/(pi*n) for the
n-th harmonic, all sine terms (for the usual odd-symmetric square wave).

**Q4. Why does the 3-harmonic approximation overshoot the square wave's
edges?**
A. The Gibbs phenomenon: truncating a series with jump discontinuities
leaves ~9% overshoot near the jump, no matter how many terms are added.

**Q5. What is the period of a 15 Hz component?**
A. T = 1/f = 1/15 ≈ 66.7 ms.

**Q6. Why must fs be much greater than 2*fmax for the FFT examples?**
A. Nyquist (fs > 2*fmax) avoids aliasing, but fs >> fmax also gives more
samples per period for readable plots and finer frequency resolution when
the duration is fixed (bin spacing = fs/N = 1/dur).

**Q7. What frequencies appear when a 5 Hz message multiplies a 50 Hz
carrier?**
A. fc - fm = 45 Hz and fc + fm = 55 Hz (the AM sidebands), each at half the
message-carrier product amplitude (0.5 V here).

**Q8. Why does multiplication create new frequencies but addition does not?**
A. Multiplication is a nonlinear operation; trig identities turn it into
sum/difference cosines. Addition is linear superposition, so each output
component just carries the inputs' frequencies.

**Q9. How does the average of the sawtooth program come out to zero?**
A. Over one period the ramp 2*(ft mod 1) - 1 is symmetric about 0; the
positive and negative areas cancel exactly. The small measured nonzero value
is sampling/quantization error.

**Q10. What Scilab function would you use to export these plots, and what
should you avoid?**
A. (If export were needed) e.g. `xs2png(scf(), 'file.png')` — but in this
lab batch mode never calls it, per the course rules: programs must run
cleanly under `exec('file.sci', -1)` without popping dialogs or absolute
paths. Plots stay on screen via `scf(n); clf(n); plot(...)`.
