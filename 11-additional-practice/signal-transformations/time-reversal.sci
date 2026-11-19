// ============================================================
// Practice Program: time-reversal.sci
// Difficulty: Beginner
// Topic: Signal transformations (time reversal)
// -----------------------------------------------------------
// PROBLEM STATEMENT: Plot x(t) and x(-t); verify even symmetry with max|x(t)-x(-t)| for a symmetric signal.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A   = 1.0;          // pulse amplitude, volts
sig = 0.15;         // width parameter of the Gaussian-like bump, seconds
fs  = 2000;         // sampling frequency, Hz
dt  = 1 / fs;       // sample spacing, seconds
t   = -0.5:dt:0.5;  // symmetric window (needed for reversal comparison)
// -------------------------------------------

// --- 1. Even (symmetric) base signal: Gaussian bump centred at 0 ---
// WHY: a symmetric signal satisfies x(t) = x(-t), so reversal changes nothing.
x_even = A * exp(-(t.^2) / (2 * sig^2));

// --- 2. Time reversal: x(-t) ---
// WHY: flipping the sign of t mirrors the waveform about the vertical axis.
x_rev = A * exp(-((-t).^2) / (2 * sig^2));   // evaluated at -t directly

// --- 3. Even-symmetry check ---
// WHY: for a true even signal the difference must be numerically ~0.
even_err = max(abs(x_even - x_rev));
mprintf("max |x(t) - x(-t)| for even signal = %e (should be ~0)\n", even_err);

// --- 4. Also show an asymmetric signal for contrast ---
x_asym = 0.5 * exp(-((t - 0.1).^2) / (2 * sig^2));   // bump shifted right of 0
x_asym_rev = 0.5 * exp(-((-t - 0.1).^2) / (2 * sig^2));
mprintf("max |x(t) - x(-t)| for shifted bump = %f (not even)\n", ...
        max(abs(x_asym - x_asym_rev)));

// --- 5. Plots: even signal and its reversal, plus asymmetric case ---
clf;
subplot(2, 1, 1);
plot(t, x_even, "b-");
plot(t, x_rev, "r--");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Even signal x(t) and x(-t): they overlap exactly");
legend("x(t)", "x(-t)"); xgrid;
subplot(2, 1, 2);
plot(t, x_asym, "b-");
plot(t, x_asym_rev, "r--");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Shifted bump x(t) and x(-t): mirror images, not equal");
legend("x(t)", "x(-t)"); xgrid;

disp("Time reversal complete.");
