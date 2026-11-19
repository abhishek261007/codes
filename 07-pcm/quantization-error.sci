// =============================================================
// Program 07.6 - Quantization Error Analysis (n = 4 bits)
// Experiment 8: PCM
// Objective: For a full-range sine quantized at n = 4 bits, study
//   e(t) = x(t) - xq(t): time waveform, histogram against the
//   theoretical uniform pdf, and error variance vs delta^2/12.
// =============================================================
// WHY: the design rule "quantization noise is white and uniform" is a
// MODEL, not a theorem - it holds only when the step is small compared
// with the signal and the input pdf is smooth. This experiment lets you
// SEE the model working (flat histogram, variance -> delta^2/12) at
// n = 4 and reason about why it fails at n = 1 or 2.
// THEORY: for e ~ U(-delta/2, delta/2), pdf(e) = 1/delta on that interval,
// variance = delta^2/12.

// ---------------- PARAMETERS ----------------
fs_s = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
t    = (0:fs_s-1)/fs_s;      // samples over [0, 1) s
m    = sin(2*%pi*fm*t);      // full-range sine in [-1, 1]
xmin = -1;                   // range minimum
xmax = 1;                    // range maximum
n    = 4;                    // bits per sample
L    = 2^n;                  // 16 levels
// ----------------------------------------------
delta = (xmax - xmin)/L;

q  = floor((m - xmin)/delta);
q  = min(max(q, 0), L-1);
mq = xmin + (q + 0.5)*delta;
e  = m - mq;                 // quantization error

var_meas = mean(e.^2);                        // ~var(e) with mean ~ 0
var_theo = delta^2/12;                        // theoretical error variance
sqnr_meas = 10*log10(mean(m.^2)/var_meas);
sqnr_theo = 6.02*n + 1.76;                    // = 25.84 dB for n = 4

disp(delta, 'Step size delta =');
disp(var_meas, 'Measured error variance (mean e^2) =');
disp(var_theo, 'Theoretical delta^2/12 =');
disp(sqnr_meas, 'Measured SQNR (dB) =');
disp(sqnr_theo, 'Theoretical 6.02*4 + 1.76 (dB) =');
mprintf('Max |e| = %.5f (must be <= delta/2 = %.5f)\n', max(abs(e)), delta/2);

// ---------------- SUBPLOT 3x1 ----------------
clf;
scf(0);

subplot(3,1,1);
plot(t, m, 'b-o', 'MarkerSize', 3);
plot(t, mq, 'r-s', 'MarkerSize', 3);
xlabel('t (s)'); ylabel('Amplitude');
title('(a) Original vs 4-bit uniform reconstruction');
legend(['original m(t)', 'xq(t)'], 'in_upper_right');
xgrid;

subplot(3,1,2);
plot(t, e, 'k-o', 'MarkerSize', 3);
xlabel('t (s)'); ylabel('e(t) = m - mq');
title('(b) Quantization error waveform');
xgrid;

subplot(3,1,3);
histplot(20, e, normalization='pdf');   // unit-area histogram, 20 bins
edel = delta/2;
plot([-edel-0.05, -edel, -edel, edel, edel, edel+0.05], ..
     [0, 0, 1/delta, 1/delta, 0, 0], 'r-', 'LineWidth', 2);
xlabel('e'); ylabel('pdf(e)');
title('(c) Error histogram vs theoretical uniform pdf (height 1/delta)');
legend(['measured histogram', 'theoretical pdf U(-delta/2, delta/2)'], 'in_upper_right');
xgrid;
