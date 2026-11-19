// sine-wave.sci
// Experiment: Signal Generation
// Objective:
//   Generate a pure sine wave in Scilab and inspect its key
//   measurements (peak amplitude and RMS value). A sine wave is the
//   building block of almost every communication signal, so this is
//   the first experiment of the lab.

// ---------------- PARAMETERS (with units) ----------------
A  = 2;      // Amplitude of the sine wave, in volts (V)
f  = 5;      // Frequency of the sine wave, in hertz (Hz)
fs = 1000;   // Sampling frequency (samples per second, Hz). fs >= 20*f avoids aliasing and keeps the plot smooth.
dur = 0.6;   // Duration of the time vector, in seconds (s). Shows about 3 periods of a 5 Hz signal.

// ---------------- TIME VECTOR ----------------
// t is a row vector of sample times from 0 to dur (exclusive of endpoint).
t = 0:1/fs:dur;

// ---------------- SIGNAL GENERATION ----------------
// y(t) = A * sin(2*pi*f*t). The .* operator is not strictly needed here
// because A is a scalar, but sin() acts element-wise on the vector t.
y = A * sin(2 * %pi * f * t);

// ---------------- MEASUREMENTS ----------------
// Peak value measured directly from the samples (should be close to A).
peak_measured = max(abs(y));
// RMS of a sine wave is A / sqrt(2). We compute it both ways.
y_rms_theory   = A / sqrt(2);
y_rms_measured = sqrt(mean(y .^ 2));

// ---------------- PLOTTING ----------------
scf(0); clf(0);
plot(t, y, 'b-', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('Amplitude y(t) (V)');
title('Sine wave: y(t) = A*sin(2*pi*f*t),  A = 2 V, f = 5 Hz');
xgrid();
legend('y(t) = 2*sin(2*pi*5*t)', 'location', 'northeast');

// ---------------- RESULTS ----------------
mprintf('\n==== Sine Wave Results ====\n');
mprintf('Amplitude A (parameter)      : %.4f V\n', A);
mprintf('Peak value (measured)        : %.4f V\n', peak_measured);
mprintf('RMS value (theoretical A/sqrt(2)): %.4f V\n', y_rms_theory);
mprintf('RMS value (measured)         : %.4f V\n', y_rms_measured);
mprintf('Frequency f                  : %.4f Hz\n', f);
mprintf('Period T = 1/f               : %.4f s\n', 1/f);
