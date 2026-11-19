// signal-addition.sci
// Experiment: Signal Generation
// Objective:
//   Add two sinusoids of very different frequencies (5 Hz message and
//   100 Hz tone) and observe that addition is superposition: the sum
//   contains both frequencies with unchanged amplitudes. This is the
//   basis of spectrum analysis and modulation.

// ---------------- PARAMETERS (with units) ----------------
A1 = 2;       // Amplitude of the low-frequency tone, in volts (V)
f1 = 5;       // Frequency of the low-frequency tone, in hertz (Hz)
A2 = 0.5;     // Amplitude of the high-frequency tone, in volts (V)
f2 = 100;     // Frequency of the high-frequency tone, in hertz (Hz)
fs = 10000;   // Sampling frequency (samples per second, Hz). Must exceed 2*f2 = 200 Hz; 10000 gives clean plots.
dur = 0.4;    // Duration, in seconds (s)

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur;

// ---------------- COMPONENT SIGNALS ----------------
s1 = A1 * sin(2 * %pi * f1 * t);
s2 = A2 * sin(2 * %pi * f2 * t);

// ---------------- SUM ----------------
s = s1 + s2;

// ---------------- PLOTTING ----------------
scf(0); clf(0);
subplot(3, 1, 1);
plot(t, s1, 'b-', 'LineWidth', 1.5);
ylabel('s1 (V)');
title('Component 1: 5 Hz, A1 = 2 V');
xgrid();

subplot(3, 1, 2);
plot(t, s2, 'g-', 'LineWidth', 1.5);
ylabel('s2 (V)');
title('Component 2: 100 Hz, A2 = 0.5 V');
xgrid();

subplot(3, 1, 3);
plot(t, s, 'r-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('s(t) (V)');
title('Sum s(t) = s1(t) + s2(t)');
xgrid();
legend('s(t)', 'location', 'northeast');

// ---------------- RESULTS ----------------
mprintf('\n==== Signal Addition Results ====\n');
mprintf('s1: A1 = %.2f V, f1 = %.1f Hz\n', A1, f1);
mprintf('s2: A2 = %.2f V, f2 = %.1f Hz\n', A2, f2);
mprintf('Sum peak (max |s|)   : %.4f V (<= A1 + A2 = %.2f V)\n', max(abs(s)), A1 + A2);
mprintf('Sum average          : %.4f V (should be ~0)\n', mean(s));
mprintf('Note: addition is linear superposition; both frequencies keep their amplitudes.\n');
