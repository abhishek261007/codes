// =============================================================
// Program 05 - Oversampling
// Experiment 2: Sampling and FFT
// Objective: Sample a 5 Hz message at 200 Hz (40x the Nyquist
// rate) and see how densely the samples trace the message - the
// reconstruction is almost trivial and the anti-alias filter
// requirements become very relaxed.
// =============================================================

// ---------------- PARAMETERS ----------------
fm      = 5;          // message frequency, Hz
Am      = 1;          // message amplitude, V
fs_s    = 200;        // sampling frequency, Hz (40 x fm, i.e. 20 x Nyquist)
T       = 0.5;        // total simulation time, s
fs_disp = 2000;       // fine grid to draw the true message
// --------------------------------------------

Ts  = 1 / fs_s;
t   = 0:1/fs_disp:T;
m   = Am * cos(2 * %pi * fm * t);

// Samples, joined by straight lines (a crude zero-order / linear
// reconstruction - good enough here BECAUSE the samples are dense)
t_s = 0:Ts:T;
s_s = Am * cos(2 * %pi * fm * t_s);

// ---------------- PLOT ----------------
scf(1);
clf(1);
plot(t, m, "k--");
plot(t_s, s_s, "b-+");
xlabel("Time (s)");
ylabel("Amplitude (V)");
legend("m(t) = cos(2*pi*5 t)", "samples at fs_s = 200 Hz (joined)");
title("Heavy oversampling: 200 Hz sampling of a 5 Hz message");
xgrid();

// Optional sinc-interpolation reconstruction check (commented out for clarity):
// A perfect band-limited reconstruction would use sinc((t - nTs)/Ts) kernels;
// with 40 samples per cycle a plain line join is already visually identical.

// ---------------- KEY NUMBERS ----------------
mprintf("\n--- Oversampling: key values ---\n");
mprintf("Message frequency fm        = %.2f Hz\n", fm);
mprintf("Nyquist rate 2*fm           = %.2f Hz\n", 2 * fm);
mprintf("Sampling frequency fs_s     = %.2f Hz\n", fs_s);
mprintf(" Oversampling factor fs_s/(2*fm) = %.1fx\n", fs_s / (2 * fm));
mprintf("Samples per message cycle   = %.1f\n", fs_s / fm);
mprintf("Sampling period Ts          = %.4f s\n", Ts);
mprintf("Number of samples in %.1f s = %d\n", T, length(t_s));
disp("First 8 samples:");
disp(s_s(1:8));

// WHY IT MATTERS:
// With fs_s = 200 Hz for a 5 Hz message, the lowest possible
// alias (495/505 Hz region) sits far above the baseband, so the
// anti-alias filter can have a gentle, cheap transition band -
// even a simple RC low-pass with cut-off somewhere between 5 Hz
// and 95 Hz works. Oversampling also spreads quantization noise
// over a wider band, improving SNR in the band of interest
// (the basis of sigma-delta ADCs in audio). Cost: more samples
// to store/process, and a faster converter.
