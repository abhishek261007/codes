// sawtooth-wave.sci
// Experiment: Signal Generation
// Objective:
//   Generate a sawtooth wave with a normalized ramp from -1 to +1:
//       saw(t) = 2 * (f*t - floor(f*t)) - 1
//   The term (f*t - floor(f*t)) is the fractional part of f*t, i.e.
//   it ramps 0 -> 1 every period. Scaling gives -1 -> +1.

// ---------------- PARAMETERS (with units) ----------------
f   = 5;      // Fundamental frequency, in hertz (Hz)
fs  = 1000;   // Sampling frequency (samples per second, Hz)
dur = 0.4;    // Duration, in seconds (s). Two periods of a 5 Hz signal.

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur;

// ---------------- SAWTOOTH WAVE ----------------
// saw(t) = 2 * (fractional part of f*t) - 1; ramps from -1 to +1 each period
saw = 2 * (f * t - floor(f * t)) - 1;

// ---------------- PLOTTING ----------------
scf(0); clf(0);
plot(t, saw, 'b-', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('Amplitude (V)');
title('Sawtooth wave: saw(t) = 2*(f*t - floor(f*t)) - 1,  f = 5 Hz');
xgrid();
legend('saw(t)', 'location', 'northeast');

// ---------------- RESULTS ----------------
// The average of a symmetric sawtooth over a full period is 0.
mprintf('\n==== Sawtooth Wave Results ====\n');
mprintf('Frequency f          : %.4f Hz\n', f);
mprintf('Theoretical range    : [-1, 1) V\n');
mprintf('Measured min         : %.4f V\n', min(saw));
mprintf('Measured max         : %.4f V\n', max(saw));
mprintf('Average value        : %.4f V (should be ~0)\n', mean(saw));
