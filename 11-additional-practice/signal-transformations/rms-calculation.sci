// ============================================================
// Practice Program: rms-calculation.sci
// Difficulty: Beginner
// Topic: RMS (root mean square) value
// -----------------------------------------------------------
// PROBLEM STATEMENT: Compute the RMS of a sine, a square wave and an arbitrary array; compare with theory.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A  = 5;             // amplitude of test signals, volts
fs = 10000;         // sampling frequency, Hz
dt = 1 / fs;        // sample spacing, seconds
t  = 0:dt:(0.1 - dt); // 0.1 s, contains an integer number of 50 Hz periods
// -------------------------------------------

// --- 1. Sine wave: RMS should be A/sqrt(2) ---
x_sine = A * sin(2 * %pi * 50 * t);
rms_sine = sqrt(mean(x_sine.^2));
mprintf("Sine RMS (computed)  = %f V\n", rms_sine);
mprintf("Sine RMS (theory A/sqrt(2)) = %f V\n", A / sqrt(2));

// --- 2. Square wave: RMS should equal A (|x| = A everywhere) ---
// sign(sin(...)) gives +1/-1; a zero crossing never lands exactly on samples here.
x_sq = A * sign(sin(2 * %pi * 50 * t));
rms_sq = sqrt(mean(x_sq.^2));
mprintf("Square RMS (computed) = %f V\n", rms_sq);
mprintf("Square RMS (theory A) = %f V\n", A);

// --- 3. Arbitrary array: just apply the definition ---
x_arb = [1, -2, 3, -4, 5];   // deliberately arbitrary numbers
rms_arb = sqrt(mean(x_arb.^2));
mprintf("Arbitrary array RMS  = %f (theory sqrt(mean(x^2)) = %f)\n", ...
        rms_arb, sqrt(mean(x_arb.^2)));

// --- 4. Why RMS matters ---
disp("RMS is the DC-equivalent heating value: P = Vrms^2 / R.");

// --- 5. Plots ---
clf;
subplot(2, 1, 1);
plot(t, x_sine, "b-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("50 Hz sine, RMS = A/sqrt(2) = 3.536 V"); xgrid;
subplot(2, 1, 2);
plot(t, x_sq, "r-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Square wave, RMS = A = 5 V"); xgrid;

disp("RMS calculation complete.");
