// ============================================================
// Practice Program: half-wave-rectifier.sci
// Difficulty: Beginner
// Topic: Rectification (half-wave)
// -----------------------------------------------------------
// PROBLEM STATEMENT: For v(t)=10 sin(2 pi 50 t), show the output of a half-wave rectifier.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A   = 10;          // peak amplitude of the sine, volts
f   = 50;          // frequency, Hz
T   = 1 / f;       // period, seconds
fs  = 10000;       // sampling frequency, Hz (dense grid for smooth plot)
dt  = 1 / fs;      // sample spacing, seconds
t   = 0:dt:(2*T);  // two full periods of the input
// -------------------------------------------

// --- 1. Generate the input sine v(t) = A sin(2 pi f t) ---
x = A * sin(2 * %pi * f * t);   // element-wise sine, volts

// --- 2. Half-wave rectification: keep only the positive half ---
// WHY: a rectifier diode conducts only when the anode is positive,
//      so the negative half-cycle is clipped to zero.
//      (x > 0) is a boolean mask; multiplying by it zeroes negatives.
y = x .* (x > 0);

// --- 3. Key numbers: peak and RMS of the output ---
peak_out = max(y);              // peak of rectified output = A (ideal diode)
rms_out  = sqrt(mean(y.^2));    // RMS of half-wave output over full periods
rms_theory = A / 2;             // theoretical RMS of half-wave rectified sine = A/2
mprintf("Peak of half-wave output (V)      = %f\n", peak_out);
mprintf("RMS of half-wave output (V)       = %f\n", rms_out);
mprintf("Theoretical RMS (A/2) (V)         = %f\n", rms_theory);

// --- 4. Plots: input vs output ---
clf;
subplot(2, 1, 1);
plot(t, x, "b-");
xlabel("Time (s)"); ylabel("Volts (V)");
title("Input sine v(t) = 10 sin(2 pi 50 t)"); xgrid;
subplot(2, 1, 2);
plot(t, y, "r-");
xlabel("Time (s)"); ylabel("Volts (V)");
title("Half-wave rectified output (negative halves clipped)"); xgrid;

disp("Half-wave rectifier complete.");
