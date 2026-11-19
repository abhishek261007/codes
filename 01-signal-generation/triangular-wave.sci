// triangular-wave.sci
// Experiment: Signal Generation
// Objective:
//   Generate a triangular wave using the identity
//       tri(t) = (2/pi) * asin(sin(2*pi*f*t))
//   This is a neat closed-form: asin(sin(theta)) folds the sine back
//   into a triangle between -pi/2 and +pi/2, and scaling by 2/pi
//   normalizes the range to [-1, 1].

// ---------------- PARAMETERS (with units) ----------------
f   = 5;      // Fundamental frequency, in hertz (Hz)
fs  = 1000;   // Sampling frequency (samples per second, Hz)
dur = 0.4;    // Duration, in seconds (s). Two periods of a 5 Hz signal.

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur;

// ---------------- TRIANGULAR WAVE ----------------
// tri(t) = (2/pi) * asin(sin(2*pi*f*t)); range is exactly [-1, 1]
tri = (2 / %pi) * asin(sin(2 * %pi * f * t));

// ---------------- PLOTTING ----------------
scf(0); clf(0);
plot(t, tri, 'b-', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('Amplitude (V)');
title('Triangular wave: tri(t) = (2/pi)*asin(sin(2*pi*f*t)),  f = 5 Hz');
xgrid();
legend('tri(t)', 'location', 'northeast');

// ---------------- RESULTS ----------------
mprintf('\n==== Triangular Wave Results ====\n');
mprintf('Frequency f          : %.4f Hz\n', f);
mprintf('Theoretical range    : [-1, 1] V\n');
mprintf('Measured peak (max)  : %.4f V\n', max(tri));
mprintf('Measured peak (min)  : %.4f V\n', min(tri));
mprintf('Measured peak abs    : %.4f V\n', max(abs(tri)));
mprintf('Average value        : %.4f V (should be ~0 by symmetry)\n', mean(tri));
