// ============================================================
// Practice Program: signal-addition.sci
// Difficulty: Beginner
// Topic: Signal transformations (addition / superposition)
// -----------------------------------------------------------
// PROBLEM STATEMENT: Show superposition by adding a 5 Hz and a 25 Hz tone and plotting the result.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
A1 = 1.0;          // amplitude of tone 1, volts
f1 = 5;            // frequency of tone 1, Hz
A2 = 0.5;          // amplitude of tone 2, volts
f2 = 25;           // frequency of tone 2, Hz
fs = 1000;         // sampling frequency, Hz
dt = 1 / fs;       // sample spacing, seconds
t  = 0:dt:0.4;     // 0.4 s window (shows both tones clearly)
// -------------------------------------------

// --- 1. Build the two component tones ---
x1 = A1 * sin(2 * %pi * f1 * t);   // 5 Hz component
x2 = A2 * sin(2 * %pi * f2 * t);   // 25 Hz component

// --- 2. Add them: superposition principle ---
// WHY: for a linear system, the response to a sum of inputs
//      equals the sum of the individual responses.
y = x1 + x2;

// --- 3. Report the amplitudes ---
mprintf("Tone 1: A1 = %f V at f1 = %d Hz\n", A1, f1);
mprintf("Tone 2: A2 = %f V at f2 = %d Hz\n", A2, f2);
mprintf("Sum peak amplitude (max |y|) = %f V\n", max(abs(y)));
mprintf("Sum RMS = %f V (theory sqrt((A1^2+A2^2)/2) = %f V)\n", ...
        sqrt(mean(y.^2)), sqrt((A1^2 + A2^2) / 2));

// --- 4. Plots: components and their sum ---
clf;
subplot(3, 1, 1);
plot(t, x1, "b-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Component 1: 5 Hz tone"); xgrid;
subplot(3, 1, 2);
plot(t, x2, "g-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Component 2: 25 Hz tone"); xgrid;
subplot(3, 1, 3);
plot(t, y, "r-");
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Sum: x1(t) + x2(t) (superposition)"); xgrid;

disp("Signal addition complete.");
