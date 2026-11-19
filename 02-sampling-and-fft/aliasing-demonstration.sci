// =============================================================
// Program 06 - Aliasing Demonstration: 5 Hz and 495 Hz
// Experiment 2: Sampling and FFT
// Objective: Show that a 5 Hz and a 495 Hz cosine sampled at
// fs = 500 Hz produce IDENTICAL sample sequences, and that both
// appear in the same FFT bin (apparent 5 Hz).
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 500;           // sampling frequency, Hz
N    = 500;           // samples = 1 second of data
T    = N / fs;        // 1 s
f1   = 5;             // tone 1, Hz
f2   = 495;           // tone 2, Hz  (= fs - f1)
Am   = 1;             // amplitude, V
// --------------------------------------------

t  = (0:N-1) / fs;
x1 = Am * cos(2 * %pi * f1 * t);
x2 = Am * cos(2 * %pi * f2 * t);

// ---------------- PLOT: identical sample sequences ----------------
scf(1);
clf(1);
subplot(2,1,1);
plot(t, x1, "b-o");
ylabel("Amplitude (V)");
title("5 Hz cosine sampled at 500 Hz");
xgrid();
subplot(2,1,2);
plot(t, x2, "r-o");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("495 Hz cosine sampled at 500 Hz - SAME sample points");
xgrid();

// ---------------- PLOT: FFTs of both ----------------
// FFT normalisation: frequency axis f = (0:N/2)*fs/N,
// single-sided amplitude = 2*|fft(x)|/N (DC & Nyquist not doubled).
f  = (0:N/2) * fs / N;    // 0..250 Hz in 1 Hz steps
X1 = 2 * abs(fft(x1)) / N;
X2 = 2 * abs(fft(x2)) / N;
X1s = X1(1:N/2+1);
X2s = X2(1:N/2+1);

scf(2);
clf(2);
subplot(2,1,1);
plot(f, X1s, "b");
ylabel("Single-Sided Magnitude");
title("FFT of x1 (5 Hz tone): peak at 5 Hz");
xgrid();
subplot(2,1,2);
plot(f, X2s, "r");
xlabel("Frequency (Hz)");
ylabel("Single-Sided Magnitude");
title("FFT of x2 (495 Hz tone): also lands in the 5 Hz bin!");
xgrid();

// ---------------- KEY NUMBERS ----------------
k_alias = round(f2 / fs);              // 1
f_alias = abs(f2 - k_alias * fs);      // 5 Hz
[Pk1, b1] = max(X1s);
[Pk2, b2] = max(X2s);
mprintf("\n--- Aliasing demonstration: key values ---\n");
mprintf("Sampling frequency fs       = %.2f Hz\n", fs);
mprintf("Nyquist frequency fs/2      = %.2f Hz\n", fs / 2);
mprintf("Tone 1                      = %.2f Hz\n", f1);
mprintf("Tone 2                      = %.2f Hz\n", f2);
mprintf("Aliasing relation f_alias   = |f - k*fs|,  k = %d\n", k_alias);
mprintf("f_alias of tone 2           = |%.0f - %d*%.0f| = %.2f Hz\n", f2, k_alias, fs, f_alias);
mprintf("Max |x1 - x2| (samples)     = %.3e V  -> sequences are IDENTICAL\n", max(abs(x1 - x2)));
mprintf("Peak bin for x1             = %.2f Hz (amplitude %.3f)\n", f(b1), X1s(b1));
mprintf("Peak bin for x2             = %.2f Hz (amplitude %.3f)\n", f(b2), X2s(b2));

// WHY IT MATTERS:
// cos(2*pi*495*n/500) = cos(2*pi*n - 2*pi*5*n/500) = cos(2*pi*5*n/500),
// so no sampling process can distinguish 5 Hz from 495 Hz. Any
// component above fs/2 folds back by k*fs. Frequency content is
// only uniquely recoverable for |f| < fs/2 - hence: anti-alias
// filter first, then sample.
