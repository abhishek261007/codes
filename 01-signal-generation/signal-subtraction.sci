// signal-subtraction.sci
// Experiment: Signal Generation
// Objective:
//   Subtract two tones (difference of two sinusoids) and observe the
//   result. Subtraction is just addition of a sign-flipped signal;
//   the difference contains both frequencies and is useful for
//   interference cancellation and differential signaling.

// ---------------- PARAMETERS (with units) ----------------
A1 = 2;       // Amplitude of tone 1, in volts (V)
f1 = 5;       // Frequency of tone 1, in hertz (Hz)
A2 = 1;       // Amplitude of tone 2, in volts (V)
f2 = 15;      // Frequency of tone 2, in hertz (Hz)
fs = 10000;   // Sampling frequency (samples per second, Hz)
dur = 0.4;    // Duration, in seconds (s)

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur;

// ---------------- COMPONENT SIGNALS ----------------
s1 = A1 * sin(2 * %pi * f1 * t);
s2 = A2 * sin(2 * %pi * f2 * t);

// ---------------- DIFFERENCE ----------------
d = s1 - s2;

// ---------------- PLOTTING ----------------
scf(0); clf(0);
subplot(3, 1, 1);
plot(t, s1, 'b-', 'LineWidth', 1.5);
ylabel('s1 (V)');
title('Tone 1: 5 Hz, A1 = 2 V');
xgrid();

subplot(3, 1, 2);
plot(t, s2, 'g-', 'LineWidth', 1.5);
ylabel('s2 (V)');
title('Tone 2: 15 Hz, A2 = 1 V');
xgrid();

subplot(3, 1, 3);
plot(t, d, 'r-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('d(t) (V)');
title('Difference d(t) = s1(t) - s2(t)');
xgrid();
legend('d(t)', 'location', 'northeast');

// ---------------- RESULTS ----------------
mprintf('\n==== Signal Subtraction Results ====\n');
mprintf('s1: A1 = %.2f V, f1 = %.1f Hz\n', A1, f1);
mprintf('s2: A2 = %.2f V, f2 = %.1f Hz\n', A2, f2);
mprintf('Difference peak      : %.4f V (<= A1 + A2 = %.2f V)\n', max(abs(d)), A1 + A2);
mprintf('Difference average   : %.4f V (should be ~0)\n', mean(d));
mprintf('Note: s1 - s2 = s1 + (-s2); the -1 flips the phase of s2 by pi radians.\n');
