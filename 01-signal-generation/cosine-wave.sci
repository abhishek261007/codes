// cosine-wave.sci
// Experiment: Signal Generation
// Objective:
//   Generate a cosine wave and show mathematically and graphically
//   that cos(wt) leads sin(wt) by a phase of pi/2 radians (90 degrees).
//   This phase relationship is essential for understanding modulation
//   and quadrature (I/Q) communication systems.

// ---------------- PARAMETERS (with units) ----------------
A   = 2;      // Amplitude, in volts (V)
f   = 5;      // Frequency, in hertz (Hz)
fs  = 1000;   // Sampling frequency (samples per second, Hz)
dur = 0.4;    // Duration, in seconds (s). Shows 2 periods of a 5 Hz signal.

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur;

// ---------------- SIGNALS ----------------
// Cosine wave: x(t) = A*cos(2*pi*f*t)
y_cos = A * cos(2 * %pi * f * t);

// Plain sine wave for comparison: s(t) = A*sin(2*pi*f*t)
y_sin = A * sin(2 * %pi * f * t);

// A time-shifted sine wave that should overlap the cosine EXACTLY.
// sin(wt + pi/2) = cos(wt), which means shifting sin LEFT by T/4
// (i.e., evaluating sin at t + T/4) produces cos(t).
T = 1 / f;                       // period in seconds
y_sin_shifted = A * sin(2 * %pi * f * (t + T/4));

// ---------------- PLOTTING ----------------
scf(0); clf(0);
subplot(2, 1, 1);
plot(t, y_cos, 'b-', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('Amplitude (V)');
title('Cosine wave: y(t) = A*cos(2*pi*f*t)');
xgrid();
legend('cos(2*pi*5*t)', 'location', 'northeast');

subplot(2, 1, 2);
plot(t, y_cos, 'b-', 'LineWidth', 2);
plot(t, y_sin_shifted, 'r--', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('Amplitude (V)');
title('cos(2*pi*f*t)  vs  sin(2*pi*f*(t + T/4))  — they overlap');
xgrid();
legend('cos(2*pi*f*t)', 'sin(2*pi*f*(t+T/4))', 'location', 'northeast');

// ---------------- RESULTS ----------------
phase_lead = %pi / 2;            // pi/2 radians
mprintf('\n==== Cosine Wave Results ====\n');
mprintf('Amplitude A                  : %.4f V\n', A);
mprintf('Frequency f                  : %.4f Hz\n', f);
mprintf('Phase difference (cos leads) : %.4f rad = %.1f degrees\n', phase_lead, phase_lead * 180 / %pi);
mprintf('Time shift T/4               : %.4f s\n', T/4);
mprintf('Max abs difference cos vs shifted-sin: %.4e V (should be ~0)\n', max(abs(y_cos - y_sin_shifted)));
