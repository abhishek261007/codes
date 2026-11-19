// ============================================================
// Practice Program: time-shifting.sci
// Difficulty: Intermediate
// Topic: Signal transformations (time shifting)
// -----------------------------------------------------------
// PROBLEM STATEMENT: Plot x(t) and the delayed x(t-t0) with t0 = 0.2 s for a gated raised-cosine pulse and explain the shift.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A   = 1.0;          // pulse amplitude, volts
t0  = 0.2;          // shift amount, seconds (delay if positive)
pw  = 0.4;          // pulse width, seconds
fs  = 2000;         // sampling frequency, Hz
dt  = 1 / fs;       // sample spacing, seconds
t   = -0.2:dt:0.8;  // plotting window covering original and shifted pulse
// -------------------------------------------

// --- 1. Base signal: raised-cosine (Hann-like) gated pulse on [0, pw] ---
// WHY: a raised cosine x(t) = A/2 * (1 + cos(2*pi*(t-pw/2)/pw)) inside the
//      gate and 0 outside is smooth, so its shift is easy to see.
x = zeros(t);
gate = (t >= 0) & (t <= pw);          // boolean mask for the pulse region
x(gate) = (A / 2) * (1 + cos(2 * %pi * (t(gate) - pw / 2) / pw));

// --- 2. Delayed version x(t - t0): same shape, moved right by t0 ---
// WHY: replacing t with (t - t0) slides the waveform to the right by t0;
//      the shape, amplitude and width are all preserved.
xs = zeros(t);
gs = (t >= t0) & (t <= pw + t0);      // shifted gate
xs(gs) = (A / 2) * (1 + cos(2 * %pi * (t(gs) - t0 - pw / 2) / pw));

// --- 3. Quantify the shift with the centroid (mean of active samples) ---
centroid_base    = sum(t .* x) / sum(x);
centroid_shifted = sum(t .* xs) / sum(xs);
mprintf("Centroid of x(t)      = %f s\n", centroid_base);
mprintf("Centroid of x(t-t0)   = %f s\n", centroid_shifted);
mprintf("Measured shift        = %f s (t0 = %f s)\n", centroid_shifted - centroid_base, t0);
disp("x(t-t0) is x(t) delayed by t0: every feature occurs t0 seconds later.");

// --- 4. Plots: original and shifted pulse ---
clf;
subplot(2, 1, 1);
plot(t, x, "b-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("x(t): raised-cosine gated pulse on [0, 0.4]"); xgrid;
subplot(2, 1, 2);
plot(t, x, "b--");
plot(t, xs, "r-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("x(t) (dashed) and x(t - 0.2) (solid): delayed by 0.2 s");
legend("x(t)", "x(t-t0)"); xgrid;

disp("Time shifting complete.");
