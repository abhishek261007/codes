// ============================================================
// Practice Program: signal-subtraction.sci
// Difficulty: Beginner
// Topic: Signal transformations (subtraction)
// -----------------------------------------------------------
// PROBLEM STATEMENT: Subtract a 25 Hz tone from a 5 Hz tone, plot the result and note the pi phase flip.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A1 = 1.0;          // amplitude of tone 1, volts
f1 = 5;            // frequency of tone 1, Hz
A2 = 0.5;          // amplitude of tone 2, volts
f2 = 25;           // frequency of tone 2, Hz
fs = 1000;         // sampling frequency, Hz
dt = 1 / fs;       // sample spacing, seconds
t  = 0:dt:0.4;     // 0.4 s window
// -------------------------------------------

// --- 1. Build the two tones ---
x1 = A1 * sin(2 * %pi * f1 * t);
x2 = A2 * sin(2 * %pi * f2 * t);

// --- 2. Subtract: y = x1 - x2 ---
// WHY: subtracting x2 is the same as adding x2 shifted by pi radians,
//      i.e. y = x1 + x2*sin(wt + pi) since sin(theta + pi) = -sin(theta).
y = x1 - x2;
x2_phase_flipped = A2 * sin(2 * %pi * f2 * t + %pi);   // equals -x2
mprintf("Max |x2 + phase_flip_version| = %e (should be ~0)\n", ...
        max(abs(x2 + x2_phase_flipped)));

// --- 3. Key numbers ---
mprintf("Tone 1: A1 = %f V at f1 = %d Hz\n", A1, f1);
mprintf("Tone 2: A2 = %f V at f2 = %d Hz (subtracted, pi phase flip)\n", A2, f2);
mprintf("Difference peak amplitude (max |y|) = %f V\n", max(abs(y)));
mprintf("Difference RMS = %f V\n", sqrt(mean(y.^2)));

// --- 4. Plots: components and the difference ---
clf;
subplot(3, 1, 1);
plot(t, x1, "b-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Component 1: 5 Hz tone"); xgrid;
subplot(3, 1, 2);
plot(t, x2, "g-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Component 2: 25 Hz tone (to be subtracted)"); xgrid;
subplot(3, 1, 3);
plot(t, y, "r-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Difference: x1(t) - x2(t)  (subtraction = pi phase flip of x2)"); xgrid;

disp("Signal subtraction complete.");
