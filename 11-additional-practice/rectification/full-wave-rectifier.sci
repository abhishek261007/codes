// ============================================================
// Practice Program: full-wave-rectifier.sci
// Difficulty: Beginner
// Topic: Rectification (full-wave)
// -----------------------------------------------------------
// PROBLEM STATEMENT: For v(t)=10 sin(2 pi 50 t), show the output of a full-wave rectifier and its DC average.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A   = 10;          // peak amplitude of the sine, volts
f   = 50;          // frequency, Hz
T   = 1 / f;       // period, seconds
fs  = 10000;       // sampling frequency, Hz
dt  = 1 / fs;      // sample spacing, seconds
t   = 0:dt:(2*T);  // two full periods
// -------------------------------------------

// --- 1. Input sine ---
x = A * sin(2 * %pi * f * t);

// --- 2. Full-wave rectification: flip the negative halves up ---
// WHY: a bridge rectifier folds every negative half-cycle above zero,
//      so the output is |v(t)| with twice the fundamental frequency.
y = abs(x);

// --- 3. DC average (mean over an integer number of periods) ---
// WHY: the average of |A sin(wt)| over a full period is 2*A/pi.
dc_computed = mean(y);     // numerical average of the output
dc_theory   = 2 * A / %pi; // theoretical average = 2A/pi ~= 6.366 V
mprintf("DC average (computed) (V)  = %f\n", dc_computed);
mprintf("DC average (2*A/pi) (V)    = %f\n", dc_theory);
mprintf("Peak of output (V)         = %f\n", max(y));

// --- 4. Plots: input, output and its mean level ---
clf;
subplot(2, 1, 1);
plot(t, x, "b-");
xlabel("Time (s)"); ylabel("Volts (V)");
title("Input sine v(t) = 10 sin(2 pi 50 t)"); xgrid;
subplot(2, 1, 2);
plot(t, y, "r-");
plot(t, dc_computed * ones(t), "k--");   // flat line at the DC level
xlabel("Time (s)"); ylabel("Volts (V)");
title("Full-wave rectified output |v(t)| with DC average 2A/pi");
legend("|v(t)|", "DC average"); xgrid;

disp("Full-wave rectifier complete.");
