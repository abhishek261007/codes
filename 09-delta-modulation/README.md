# 09 — Delta Modulation (Experiment 10)

## Objective

Study Delta Modulation (DM) and Adaptive Delta Modulation (ADM): encode an
oversampled message into a 1-bit-per-sample stream, reconstruct it with an
integrator at the receiver, and observe the two classic failure modes of
fixed-step DM — **slope overload** (step too small for a steep message) and
**granular noise** (step too large for a quiet message) — and how ADM cures both.

## Theory

**DM principle.** Delta modulation approximates the message with a staircase
function. At each sampling instant the encoder compares the message `x(n)` with
the running reconstruction `xhat` and transmits only the SIGN of the difference:

- `b(n) = 1` if `x(n) >= xhat` (staircase should step UP)
- `b(n) = 0` otherwise (staircase should step DOWN)

The receiver is a simple integrator: it adds `+delta` on a `1` and `-delta` on a
`0`. Because both sides start from the same zero initial condition and apply the
same rule to the same bit stream, the receiver output is bit-identical to the
encoder's internal `xhat`. Each sample costs exactly **1 bit**.

**Staircase approximation.** The reconstruction is a staircase that tracks the
message with one quantization step `delta` of resolution. An output low-pass
filter can smooth the stairs into an analog-looking waveform, but DM is
fundamentally a 1-bit quantizer of the *slope*, not of the amplitude.

**Slope overload condition.** The staircase can climb at most `delta` per
sample, i.e. a maximum slope of `delta * fs_s` per second. To avoid slope
overload:

```
delta >= max|dx/dt| / fs_s
```

For `x = A*sin(2*pi*fm*t)`, `max|dx/dt| = A*2*pi*fm`, so with `A = 1, fm = 5 Hz,
fs_s = 100 Hz` we need `delta >= 0.314`. Below that, the staircase lags the
message and the reconstruction collapses into a clipped, delayed version of it.

**Granular noise.** For large `delta`, on slow or constant segments the
reconstruction cannot settle: it overshoots the message, steps back, overshoots
again — a permanent "hunting" oscillation of peak-to-peak amplitude about
`delta`. This is granular noise. It is worst on quiet passages, exactly where
slope overload is impossible.

**The trade-off.** Fixed-step DM forces one `delta` to serve both regimes:
large `delta` cures slope overload but worsens granular noise; small `delta`
cures granular noise but reintroduces slope overload. Raising `fs_s` helps both
(slope capability scales with `fs_s`) but costs bandwidth — DM typically runs at
`fs_s` far above Nyquist (e.g. 100 Hz here vs 2 Hz Nyquist).

**Adaptive DM (Jayant / Gopal rule).** Make the step size track the signal:

- if `b(n) == b(n-1)` (two equal bits — staircase falling behind): `delta <- min(delta*K, delta_max)`
- if `b(n) != b(n-1)` (alternating bits — staircase hunting):   `delta <- max(delta/K, delta_min)`

with `K = 1.5`, `delta_min = 0.01`, `delta_max = 0.5`. The receiver applies the
identical rule to the bit stream alone, so no extra information is transmitted
and the two sides never drift. ADM handles steep flanks (large delta) and quiet
zones (small delta) with the same 1 bit per sample.

**Comparison: DM vs PCM vs DPCM**

| Property | DM | DPCM | PCM |
|---|---|---|---|
| Bits per sample | 1 | R (e.g. 4) | B (e.g. 8) |
| What is quantized | sign of prediction error | prediction error | the sample itself |
| Encoder complexity | very low (comparator + integrator) | low (predictor + quantizer) | low |
| Decoder complexity | very low (integrator) | low | low |
| Predictor | implicit (integrator / zero-order) | explicit (e.g. zero-order) | none |
| Oversampling needed | yes, heavily | mild | no (Nyquist) |
| Noise trade-off | slope overload + granular noise | quantization noise only | quantization noise only |
| Quality at same bit rate | worst, needs bandwidth | good | reference "best per bit at low rates" |
| Best for | simple/robust links, speech at low rate | speech, image coding | general purpose |

## Parameter meanings

| Symbol | Meaning | Value used |
|---|---|---|
| `fs_s` | sampling (step) rate of the DM loop, Hz | 100 |
| `fm` | message frequency, Hz | 1, 2 or 5 |
| `Am` | message amplitude | 1 (or 0.3 DC for granular noise) |
| `delta` | fixed DM step size | 0.05 / 0.1 / 0.3 / 0.35 |
| `N` | number of samples = number of bits | 100 |
| `t` | time axis `0:1/fs_s:1-1/fs_s` | 1 s |
| `K` | Jayant ADM adaptation factor | 1.5 |
| `delta_min`, `delta_max` | ADM step clamp | 0.01, 0.5 |
| `bits` | transmitted 1-bit stream (1 = step up, 0 = step down) | — |
| `xhat` | staircase reconstruction (identical on TX and RX) | — |
| `err`, `mse` | reconstruction error and mean squared error | — |

## How to run

Scilab 2024.1 on Linux. From a fresh session:

```bash
cd /home/abhishek/scilab-communications-lab/09-delta-modulation
scilab -nw -nb -e "exec('delta-modulation.sci', -1)"
scilab -nw -nb -e "exec('slope-overload-distortion.sci', -1)"
scilab -nw -nb -e "exec('granular-noise.sci', -1)"
scilab -nw -nb -e "exec('adaptive-delta-modulation.sci', -1)"
```

Or open Scilab, `cd` into the folder, and `exec('delta-modulation.sci', -1)`.
Each script prints key numbers to the console and opens one figure window.

## Expected plots and interpretation

1. **delta-modulation.sci** (good case, `fm = 1`, `delta = 0.1`):
   top subplot — smooth sine `x(t)` overlaid with the red dashed staircase
   reconstruction that tracks it closely; bottom subplot — the small error, a
   bounded granular ripple. Console: `Max |error| = 0.1000`,
   `Mean squared err = 0.003351`, `Bits transmitted = 100`. Confirms the
   slope-overload condition `delta >= A*2*pi*fm/fs_s = 0.0628` is met.

2. **slope-overload-distortion.sci** (bad vs good):
   2x2 figure. Top-left — `delta = 0.05`, the staircase visibly lags and
   collapses below the message amplitude (slope overload); top-right — the
   large structured error; bottom-left — `delta = 0.35`, clean tracking;
   bottom-right — the residual small ripple. Console: `MSE = 0.4460` for
   `delta = 0.05` vs `MSE = 0.0560` for `delta = 0.35`. The cure is a larger
   `delta` (or higher `fs_s`, or ADM), nothing else.

3. **granular-noise.sci** (constant input, `x(t) = 0.3`, `delta = 0.3`):
   top subplot — flat blue line at 0.3 with the red staircase overshooting
   above and below it forever; bottom subplot — error that never decays.
   Console: `MSE = 0.045`, steady-state peak-to-peak hunting amplitude
   `= 0.3000 ≈ delta`. Demonstrates that large `delta` is unusable on quiet
   signals even though it is required on steep ones.

4. **adaptive-delta-modulation.sci** (ADM on the hard signal, `fm = 5`, `A = 1`):
   top subplot — message vs ADM reconstruction (green dashed, tracks well) vs
   fixed-DM reconstruction with `delta = 0.05` (red dotted, collapsed); bottom
   subplot — the adaptation trace `delta(n)` which grows on the steep flanks
   and shrinks near the peaks/zero crossings. Console: fixed DM `MSE = 0.4460`
   vs ADM `MSE = 0.0935`; step size ends near `0.148`.

## Observations

- DM sends exactly 1 bit per sample; 100 samples → 100 bits, regardless of
  signal complexity.
- The decoder output is bit-identical to the encoder's internal staircase; no
  drift can occur because both sides integrate the same signed steps from the
  same zero start.
- Slope overload is not random noise — it is a deterministic lag caused by
  `delta*fs_s < max|dx/dt|`, and it worsens with higher `fm` or larger `A`.
- Granular noise does not average to zero on a DC message; the hunting
  amplitude equals one full step `delta`.
- ADM recovers most of the gap (MSE 0.446 → 0.094) with the same 1 bit/sample,
  at the cost of one extra multiply/clamp per sample on both sides.
- DM quality is bought with bandwidth (heavy oversampling), not with bits.

## Common mistakes

- **fs_s chosen too low.** DM is meaningless at Nyquist rate; keep `fs_s`
  10–50x the message bandwidth, or slope overload is unavoidable.
- **delta picked without the slope check.** Always verify
  `delta >= A*2*pi*fm/fs_s` (or the equivalent for your message) before
  blaming the decoder.
- **Confusing the bit convention.** Here `1 = step up, 0 = step down`. If your
  decoder uses the opposite convention the reconstruction diverges instantly —
  if TX and RX disagree on the sign, you get maximum error, not a small offset.
- **Decoder drift from sign/step mismatch.** Any mismatch in `delta`, sign
  convention, or initial condition between encoder and decoder integrates up
  sample after sample; both sides must run the identical update rule.
- **Expecting the output LP filter to cure granular noise.** Low-pass smoothing
  hides the staircase/hunting ripple for display but cannot recover the lost
  slope information; the fix is a smaller (or adaptive) `delta`.
- **Resetting xhat mid-stream.** The reconstruction is stateful; starting it
  from anything other than the shared zero initial condition breaks the
  bit-identical TX/RX property.

## Viva questions with answers

1. **What is Delta Modulation?**
   A 1-bit differential pulse modulation scheme where the encoder transmits only
   the sign of the difference between the message and a staircase reconstruction;
   the decoder is a simple integrator that steps up or down by `delta`.

2. **Why is DM called a 1-bit quantizer?**
   At each sample the error is reduced to a single bit (above/below the
   reconstruction); the quantization interval is the step `delta`, not an
   amplitude level.

3. **What is slope overload distortion?**
   When the message changes faster than the staircase can follow
   (`max|dx/dt| > delta*fs_s`), the reconstruction lags and clips the true slope,
   producing large structured error.

4. **State the slope overload condition mathematically.**
   Avoid overload iff `delta >= max|dx/dt| / fs_s`. For a sine of amplitude `A`
   and frequency `fm`: `delta >= A*2*pi*fm/fs_s`.

5. **What is granular noise?**
   The permanent hunting oscillation of the staircase around a slowly varying or
   constant message when `delta` is too large; peak-to-peak amplitude ≈ `delta`.

6. **Why can't one fixed delta avoid both slope overload and granular noise?**
   They pull in opposite directions: steep segments demand large `delta`, quiet
   segments demand small `delta`. A single value always fails one regime on
   real (multi-slope) signals.

7. **How does DM relate to DPCM?**
   DM is the simplest DPCM: a zero-order predictor (previous reconstruction,
   i.e. an integrator) and a 1-bit quantizer of the prediction error. DPCM
   generalizes this with better predictors and multi-bit quantizers.

8. **Why must DM be oversampled so heavily?**
   The staircase rises only `delta` per sample; to make `delta` small enough for
   good tracking without slope overload, you need many samples per message
   cycle — far above the 2 samples/cycle Nyquist minimum.

9. **What is Adaptive Delta Modulation?**
   DM with a step size that adapts per sample: it grows when consecutive bits are
   equal (signal running ahead) and shrinks when they alternate (staircase
   hunting), clamped to `[delta_min, delta_max]`.

10. **Describe the Jayant (Gopal) adaptation rule.**
    `delta(n) = min(delta(n-1)*K, delta_max)` if `b(n) == b(n-1)`, else
    `delta(n) = max(delta(n-1)/K, delta_min)`, with `K ≈ 1.5`. The same rule is
    applied at the receiver using only the bit stream.

11. **How is the bit rate of DM calculated?**
    Exactly `fs_s` bits per second (1 bit per sample), independent of the
    message — e.g. 100 bits per second at `fs_s = 100 Hz`.

12. **What are the advantages and disadvantages of DM?**
    Advantages: extreme encoder/decoder simplicity (comparator + integrator),
    1 bit/sample, robust to small amplitude errors, easy to implement and to
    adapt. Disadvantages: needs heavy oversampling (bandwidth cost), slope
    overload and granular noise in fixed form, poorer SNR than PCM at high rates;
    ADM mitigates the noise trade-off at the cost of slight complexity.
