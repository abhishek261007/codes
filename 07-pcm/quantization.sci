// =============================================================
// Program 07.1 - Quantization of a Sinusoidal Message
// Experiment 8: PCM
// Objective: Quantize a sine wave (fm = 2 Hz, fs_s = 50 Hz) with a
//   UNIFORM MID-TREAD quantizer using n = 3 bits (L = 2^3 = 8 levels)
//   over the range [-1, 1], plot the original and the reconstructed
//   staircase, and measure the mean squared quantization error.
// =============================================================
// WHY uniform mid-tread: it is the simplest quantizer to analyse -
// every reconstruction level sits at the CENTRE of a decision cell,
// so the quantization error is symmetric for positive and negative
// inputs. We implement it as q = floor((x - xmin)/delta) clipped to
// [0, L-1] and reconstruct as xmin + (q + 0.5)*delta. Strictly this
// is a "mid-tread-like" quantizer: with an EVEN number of levels a
// true mid-tread (a reconstruction level exactly at 0) is not
// possible, so we place levels at cell centres - document this
// approximation. The error statistics are identical.
// WHY n = 3 (L = 8): coarse enough to SEE the staircase, fine enough
// to see the error shrinking - a teaching compromise.

// ---------------- PARAMETERS ----------------
fs_s = 50;                   // sampling frequency, Hz (>= 2*fm = 4 Hz, OK)
fm   = 2;                    // message frequency, Hz
t    = (0:fs_s-1)/fs_s;      // 50 samples over t in [0, 1) s
m    = sin(2*%pi*fm*t);      // message signal, normalized to [-1, 1]
n    = 3;                    // bits per sample
L    = 2^n;                  // number of quantization levels = 8
xmin = -1;                   // assumed signal range minimum
xmax = 1;                    // assumed signal range maximum
// ----------------------------------------------

// ---- Step size (all levels have equal width delta) ----
delta = (xmax - xmin)/L;     // quantization step = 2/8 = 0.25

// ---- Quantize: index -> clip -> reconstruct ----
q = floor((m - xmin)/delta); // raw cell index (may fall OUTSIDE [0,L-1] at edges)
q = min(max(q, 0), L-1);     // ALWAYS clip: samples near +1 give q = L otherwise
mq = xmin + (q + 0.5)*delta; // cell-centre reconstruction (mid-tread-ish)

// ---- Error ----
e = m - mq;                  // quantization error e = x - xq
mse = mean(e.^2);            // measured mean squared quantization error
sqnr_meas = 10*log10(mean(m.^2)/mse);   // measured SQNR, dB
sqnr_theo = 6.02*n + 1.76;   // full-scale sine rule, dB (valid for large n, full range)

// ---------------- RESULTS ----------------
disp(L,   'Number of levels L = 2^n =');
disp(delta, 'Step size delta = (xmax-xmin)/L =');
disp(mse,  'Mean squared quantization error =');
disp(sqnr_meas, 'Measured SQNR (dB) =');
// WHY the theory number: for a FULL-RANGE SINE the signal power is A^2/2 with
// A = 1, and the error is ~ U(-delta/2, delta/2) with variance delta^2/12.
//   SQNR = (A^2/2) / (delta^2/12) = 6.02*n + 1.76 dB  ->  6.02*3 + 1.76 = 19.82 dB.
// For n = 3 the assumption (error flat, many levels) is only rough, so the
// measured value will differ - that is expected and is the lesson.
disp(sqnr_theo, 'Theoretical SQNR 6.02*n + 1.76 (dB) =');

// ---------------- PLOT ----------------
clf;
scf(0);
plot(t, m, 'b-o', 'MarkerSize', 4);      // original message (samples, smooth join shown)
plot(t, mq, 'r-s', 'MarkerSize', 4);     // reconstructed staircase (markers joined)
xlabel('t (s)');
ylabel('Amplitude');
title('Uniform mid-tread quantization: fm = 2 Hz, fs_s = 50 Hz, n = 3 bits (L = 8)');
legend(['original m(t)', 'reconstructed xq(t)'], 'in_upper_right');
xgrid;

// NOTE: Scilab's plot() joins points with straight lines - the "staircase"
// is therefore drawn as a piecewise-linear join through the level centres.
// It shows exactly the same information as a true step plot: the number of
// distinct amplitude levels (here 8) is directly visible as flat-ish bands.
