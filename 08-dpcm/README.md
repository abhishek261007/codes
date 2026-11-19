# 08 — DPCM (Experiment 9)

## Objective

Understand Differential PCM end-to-end: why a correlated (oversampled) signal is
better coded by quantizing the **prediction error** instead of the raw signal,
why the **encoder and decoder predictors must use the decoder-side
reconstruction** (never the original message), and how much SQNR DPCM gains over
PCM at the same bit rate.

## Theory

- **Zero-order predictor:** `x_hat(n) = x_rec(n-1)` — predict the next sample as
  the *previous reconstructed* sample. (A first-order predictor uses
  `2*x_rec(n-1) - x_rec(n-2)`; zero-order is enough for a slowly varying sine.)
- **Prediction error:** `e(n) = x(n) - x_hat(n)`.
- **Uniform quantization of the error** over `[-Emax, +Emax]` with `L` levels:
  `delta = 2*Emax/L`, `eq = clip(floor(e/delta + 0.5)*delta, -Emax, +Emax)`.
- **Encoder/decoder consistency — the golden rule:** the predictor must use
  `x_rec(n-1)`, the DECODER-side reconstruction, never the original `x`. The
  decoder never sees `x`; if the encoder predicted from `x`, the two sides would
  make different predictions after the first quantization error and the
  reconstruction would **drift without bound**. By sharing the same predictor and
  the same reconstructed history, both ends stay bit-true in sync (verified in
  `dpcm-decoding.sci`: `max |x_rec - x_hat| = 0`).
- **Reconstruction (integration):** `x_rec(n) = x_hat(n) + eq(n)`. The decoder is
  an accumulator driven by the quantized-error stream — integrating a small
  error signal reproduces the large message.
- **SQNR advantage:** for a correlated source, error energy << signal energy, so
  `SQNR_dpcm ≈ SQNR_pcm + Gp` with prediction gain
  `Gp = 10*log10(var(x)/var(e))`. Practical gains are **4–11 dB** over PCM at
  equal bit rate; here we measure ≈ **7.7 dB**. Equivalently, DPCM needs ≈ 1–2
  fewer bits per sample for the same quality.
- **Single-pass loop:** prediction, quantization and reconstruction are done in
  ONE loop at the encoder, because the encoder's `x_rec` IS the decoder's
  output. `dpcm-decoding.sci` splits this into two explicit loops (TX / RX)
  to mimic two real terminals.
- **Bit saving:** only the `eq` symbols (4 bits here) + the shared parameters
  `(Emax, L, predictor)` cross the link — never the raw samples.

## Parameter meanings

| Symbol | Value | Meaning |
|--------|-------|---------|
| `fs`   | 50 Hz | sampling frequency (oversampling ratio fs/fm = 25, so sample-to-sample correlation is high) |
| `fm`   | 2 Hz  | message frequency |
| `Am`   | 1     | message amplitude |
| `Emax` | **0.3** | error-quantizer full-scale range; MUST exceed max possible `|e| = 2*Am*sin(pi*fm/fs) ≈ 0.251` (see note below) |
| `L`    | 16    | error-quantizer levels (4 bits/sample) |
| `delta`| `2*Emax/L` = 0.0375 | quantizer step size |
| `Gp`   | ≈ 12.2 dB | prediction gain for this signal |

> **Important design note (Emax).** The peak amplitude difference between
> adjacent samples is `2*Am*sin(pi*fm/fs) = 2*sin(pi/25) ≈ 0.251`. An earlier
> draft used `Emax = 0.2`, which **clips every error peak**. Clipped errors
> feed back through the predictor, the reconstruction drifts (measured max
> `|e|` grew to ≈ 0.39) and DPCM collapsed to 18.4 dB — **below** 4-bit PCM
> (27.8 dB). `Emax = 0.3` is the smallest safe value and is used in all three
> programs. Do not "simplify" it back to 0.2.

## How to run

```bash
cd /home/abhishek/scilab-communications-lab/08-dpcm
scilab -nw -nb -e "exec('dpcm-encoding.sci', -1)"
scilab -nw -nb -e "exec('dpcm-decoding.sci', -1)"
scilab -nw -nb -e "exec('dpcm-reconstruction.sci', -1)"
```

(or open the `.sci` files in SciNotes and press F5 / Execute.)

## Expected plots and interpretation

**dpcm-encoding.sci** — `scf(0)`, two subplots:
- Top: message `x(n)` (blue `*`) vs DPCM reconstruction `x_rec(n)` (red `o`).
  They overlay almost perfectly — the reconstruction hugs the samples.
- Bottom: prediction error `e(n)` (green) vs quantized error `eq(n)` (black
  dashed `*`). `e(n)` is tiny compared with `x(n)` (peak ≈ 0.26 vs 1.0); `eq(n)`
  is its staircase approximation.
- Prints max `|e|` = 0.2625, `delta` = 0.0375, MSE ≈ 1.41e-4, **DPCM SQNR ≈ 35.5 dB**.

**dpcm-decoding.sci** — two subplots:
- Top: original `x(n)` (blue) vs decoded `x_hat(n)` (red dashed `o`) — identical.
- Bottom: end-to-end error `x(n) - x_hat(n)` (magenta `*`), peak ≈ 0.02.
- Prints `max |x_rec - x_hat| = 0` (encoder/decoder bit-true sync), MSE ≈ 1.41e-4,
  SQNR ≈ 35.5 dB, total link load 50 samples × 4 bits = 200 bits.

**dpcm-reconstruction.sci** — two subplots:
- Top: original vs PCM 4-bit reconstruction (green dashed, visibly coarser) vs
  DPCM 4-bit reconstruction (red dashed, hugs the original).
- Bottom: `bar([sqnr_pcm, sqnr_dpcm])` — two bars, ≈ 27.8 dB vs ≈ 35.5 dB.
- Prints both SQNRs, advantage ≈ **+7.65 dB** for DPCM at equal bits.

## Observations

1. DPCM exploits sample-to-sample correlation: the prediction error of a
   sine sampled at `fs = 25×fm` has ~12 dB less variance than the signal.
2. Quantizing the small error with the same 4 bits gives a finer effective
   step (0.0375 vs PCM's 0.125) — that is where the 7–8 dB comes from.
3. Encoder and decoder stay perfectly in sync **only because** the predictor
   uses the reconstruction. The decoder needs just the `E_Q` stream plus the
   agreed `(Emax, L, predictor)` — zero drift, no side information about `x`.
4. If `Emax` is too small (0.2 < 0.251) the quantizer clips, the error
   feedback loop diverges (max `|e|` → 0.39) and DPCM becomes *worse* than
   PCM — a dramatic demonstration that range design matters more than level count.
5. DPCM is fragile to channel errors: one corrupted `E_Q` symbol perturbs the
   reconstruction until the predictor re-converges (PCM has no such memory).

## Common mistakes

1. **Using the original `x` in the decoder's predictor** — instant encoder/
   decoder mismatch and unbounded drift. The predictor must use `x_rec` / `x_hat`.
2. **`Emax` too small** → error clipping (see note above). Always check
   `max |e| ≤ Emax` or you will get silent quality collapse.
3. **Forgetting the 1-sample delay:** `pred(n)` uses `x_rec(n-1)`, not `x_rec(n)`
   (that would be a delay-0 predictor needing the answer you are computing).
4. **Predictor order confusion:** zero-order = `x_rec(n-1)`; first-order =
   extrapolation `2*x_rec(n-1) - x_rec(n-2)`. Pick one and use the SAME order at
   both ends.
5. **Mid-tread vs mid-step bookkeeping:** levels are at
   `..., -delta, 0, +delta, ...` via `floor(e/delta + 0.5)*delta`; forgetting
   the `+0.5` makes it a truncation quantizer with biased error.
6. **Comparing DPCM and PCM at different bit rates** — only equal-bit
   comparisons (like `dpcm-reconstruction.sci`) are meaningful.

## Viva questions with answers

**Q1. What is DPCM and how does it differ from PCM?**
A. DPCM quantizes the *difference* between the actual sample and a prediction of
it (usually from previous *reconstructed* samples), instead of quantizing the
sample itself. For correlated signals this error occupies a smaller range, so
the same bits buy a finer step and higher SQNR.

**Q2. Why must the predictor use the reconstructed sample and not the original?**
A. The decoder never has the original. If the encoder predicted from `x`, its
prediction would differ from the decoder's (which can only use what it
reconstructed) after the first quantization error — the mismatch would
accumulate and the received signal would drift arbitrarily far from the sent one.

**Q3. Write the reconstruction equation at the decoder.**
A. `x_hat(n) = x_hat(n-1) + E_Q(n)`, with `x_hat(1) = E_Q(1)` (prediction 0 for
the first sample). The decoder is an integrator of the quantized-error stream.

**Q4. What is the prediction gain Gp?**
A. `Gp = 10*log10(var(x) / var(e))` — the ratio of signal power to prediction-
error power, in dB. For this signal it is ≈ 12 dB; DPCM ideally inherits this on
top of PCM's SQNR.

**Q5. Why is `Emax` chosen as 0.3 here, not 0.2?**
A. The largest possible error is `2*Am*sin(pi*fm/fs) ≈ 0.251`. With `Emax = 0.2`
the error clips every cycle, clipped error feeds back through the predictor,
and the reconstruction drifts (max `|e|` → 0.39), collapsing SQNR to 18.4 dB —
worse than PCM. `Emax` must exceed the worst-case error.

**Q6. What happens if a channel bit error corrupts one `E_Q` symbol?**
A. The single wrong value is integrated into `x_hat` and the error persists
(slowly decaying as the predictor re-anchors on the next samples). PCM errors
affect only one sample. This memory of DPCM is the price of the bit saving.

**Q7. Why is oversampling (fs >> fm) essential for DPCM to win?**
A. Correlation between adjacent samples comes from the signal changing little
between samples. If `fs = 2*fm` (Nyquist), consecutive sine samples can be
nearly opposite (correlation ≈ 0) and the error is as large as the signal —
DPCM then ties PCM and wastes bits. Here `fs/fm = 25`, correlation ≈ 0.97.

**Q8. How many bits does the DPCM link carry for this experiment, and what does the decoder need besides the bits?**
A. `50 samples × 4 bits = 200 bits`. The decoder additionally needs the shared
`Emax`, `L` and the predictor definition/starting condition — this is the only
"side information".

**Q9. How would you improve on fixed zero-order DPCM?**
A. Use a first-order (or adaptive) predictor, and/or make the quantizer step
adaptive: *delta modulation* uses 1 bit and a fixed step; *ADPCM / adaptive
delta modulation* scales the step by recent error magnitude (e.g. increase the
step when consecutive errors share sign). That is the subject of the next
experiment (09-delta-modulation).

**Q10. Is DPCM lossy? Can you recover the exact original?**
A. Yes, it is lossy — only the quantized error crosses the link, so
`x_rec ≠ x` in general (MSE ≈ 1.4e-4 here). Perfect recovery would need a
lossless predictive coder (differential coding without quantization). In a real
DPCM link, `x_rec` is the agreed reference for the NEXT sample, which is why
small distortion does **not** become instability.
