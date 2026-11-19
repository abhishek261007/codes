// =============================================================
// Program 04.5 - FM Demodulation by Differentiation + Envelope
// Experiment 4: FM Transmission and Reception
// Objective: Demodulate an FM signal (beta = 2) with the classic
//            differentiator + envelope detector: s -> diff() -> abs()
//            -> moving-average low-pass (L = 100) -> subtract DC.
//            Recover the message shape, overlay with m(t), and disp
//            the correlation coefficient (expect > 0.9).
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
beta = 2;              // moderate modulation index for a clean demo
df   = beta * fm;      // deviation, Hz (df = 20 Hz)
kf   = df / Am;        // kf = 20 Hz/V
L    = 100;            // moving-average length, samples
Tdur = 0.4;            // 0.4 s -> 4 message cycles
N    = round(fs * Tdur);
// --------------------------------------------
// WHY L = 100: the envelope after differentiation contains the message
// (fm = 10 Hz) plus ripple at 2*fc = 400 Hz. A moving average of length L
// has its first null at fs/L = 100 Hz, so it passes fm = 10 Hz nearly
// untouched (~2% sinc loss) while strongly rejecting the 400 Hz ripple.

t = (0:N-1) / fs;
m = Am * cos(2 * %pi * fm * t);
phase = 2 * %pi * fc * t + 2 * %pi * kf * cumsum(m) / fs;   // phase integration
s     = Ac * cos(phase);

// ---- Demodulator chain ----
// 1) Differentiate: d/dt s(t) = -Ac*phi'(t)*sin(phi(t)), phi' = 2*pi*(fc + kf*m(t))
//    The amplitude of this differentiated signal is proportional to (fc + kf*m(t)).
ds = diff(s) * fs;                 // multiply by fs: diff gives per-sample, not per-second
ds = [ds(1), ds];                  // prepend one point to keep length N (reuse first sample)

// 2) Envelope (rectify) + 3) moving-average low-pass filter
y_abs = abs(ds);
y_lp  = filter(ones(1, L) / L, 1, y_abs);   // FIR moving average

// Compensate the group delay of the moving average (~ (L-1)/2 samples) so the
// recovered message lines up with m(t) for a fair correlation measurement.
d = floor((L - 1) / 2);            // 49 samples ~ 4.9 ms << 1 message period (100 ms)
rec = y_lp(d + 1:N) - mean(y_lp);  // subtract DC (the fc term), keep the message part
m_cmp = m(1:N - d);

// WHY steady-state only: the FIR moving average starts from a zero initial
// state, so the first ~L samples are a start-up transient, not the true
// envelope. Correlating over the steady-state region is the fair comparison.
i0 = L + 50;                      // skip start-up transient (150 samples)
rec_ss = rec(i0+1:$);
m_ss   = m_cmp(i0+1:$);

// Normalize both for shape comparison
rec_n = rec_ss / max(abs(rec_ss));
m_n   = m_ss / max(abs(m_ss));

// Correlation coefficient, computed manually: cov / (std * std)
r_mean = mean(rec_n);
m_mean = mean(m_n);
cov_rm = mean((rec_n - r_mean) .* (m_n - m_mean));
var_r  = mean((rec_n - r_mean) .^ 2);
var_m  = mean((m_n - m_mean) .^ 2);
corr   = cov_rm / sqrt(var_r * var_m);

scf(1);
clf(1);
subplot(3,1,1);
plot(t, s, "r");
ylabel("Amplitude (V)");
title("FM signal (beta = 2) entering the demodulator");
xgrid();
subplot(3,1,2);
plot(t, y_lp, "k");
ylabel("Envelope (V)");
title("After diff -> abs -> moving average (L = 100): large DC term + message ripple");
xgrid();
subplot(3,1,3);
plot(t(i0+1:N-d), m_n, "b", t(i0+1:N-d), rec_n, "g--");
xlabel("Time (s)");
ylabel("Normalized amplitude");
title("Recovered message (green dashed) vs original m(t) (blue), steady-state region");
legend("m(t) normalized", "recovered (normalized)");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 4 / fm-demodulation - KEY RESULTS");
mprintf("beta                       = %f\n", beta);
mprintf("Moving average length L    = %d samples  (first null at fs/L = %f Hz)\n", L, fs/L);
mprintf("Group delay compensated    = %d samples (%f ms)\n", d, d/fs*1000);
mprintf("Correlation window         = samples %d..%d (steady state, transient excluded)\n", i0+1, N-d);
mprintf("Correlation coefficient    = %f   (expect > 0.9)\n", corr);
mprintf("Note: FM noise-robustness / improvement threshold is a course topic; this demo uses a clean channel.\n");
mprintf("The large DC offset is the fc term; the ripple around it is proportional to kf*m(t).\n");
