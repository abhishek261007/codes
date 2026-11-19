// composite-signal.sci
// Experiment: Signal Generation
// Objective:
//   Build a composite (multi-harmonic) signal by adding three sine
//   waves at f, 2f and 3f. This demonstrates how Fourier synthesis
//   builds complex waveforms (e.g., square/triangle approximations)
//   from simple sinusoids.

// ---------------- PARAMETERS (with units) ----------------
A1 = 1;      // Amplitude of fundamental (1st harmonic), in volts (V)
A2 = 0.5;    // Amplitude of 2nd harmonic, in volts (V)
A3 = 0.33;   // Amplitude of 3rd harmonic (3rd-ish harmonic mix), in volts (V)
f  = 5;      // Fundamental frequency, in hertz (Hz)
fs = 10000;  // Sampling frequency (samples per second, Hz). 10000 >> 20*3*f keeps everything smooth.
dur = 0.4;   // Duration, in seconds (s). Two periods of the 5 Hz fundamental.

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur;

// ---------------- COMPONENT SIGNALS ----------------
c1 = A1 * sin(2 * %pi * f * t);        // fundamental
c2 = A2 * sin(2 * %pi * 2 * f * t);    // 2nd harmonic
c3 = A3 * sin(2 * %pi * 3 * f * t);    // 3rd harmonic

// ---------------- COMPOSITE SIGNAL ----------------
// s(t) = A1*sin(2*pi*f*t) + A2*sin(2*pi*2*f*t) + A3*sin(2*pi*3*f*t)
s = c1 + c2 + c3;

// ---------------- PLOTTING ----------------
scf(0); clf(0);

// Stacked components, one per subplot row
subplot(4, 1, 1);
plot(t, c1, 'b-', 'LineWidth', 1.5);
ylabel('c1 (V)');
title('Component 1: fundamental, f = 5 Hz, A1 = 1 V');
xgrid();

subplot(4, 1, 2);
plot(t, c2, 'g-', 'LineWidth', 1.5);
ylabel('c2 (V)');
title('Component 2: 2nd harmonic, 2f = 10 Hz, A2 = 0.5 V');
xgrid();

subplot(4, 1, 3);
plot(t, c3, 'm-', 'LineWidth', 1.5);
ylabel('c3 (V)');
title('Component 3: 3rd harmonic, 3f = 15 Hz, A3 = 0.33 V');
xgrid();

subplot(4, 1, 4);
plot(t, s, 'r-', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('s(t) (V)');
title('Composite signal s(t) = c1 + c2 + c3');
xgrid();
legend('s(t)', 'location', 'northeast');

// ---------------- RESULTS ----------------
// The fundamental carries the most power (largest amplitude), so the
// dominant frequency is the fundamental f itself.
mprintf('\n==== Composite Signal Results ====\n');
mprintf('Component amplitudes: A1 = %.2f V, A2 = %.2f V, A3 = %.2f V\n', A1, A2, A3);
mprintf('Component frequencies: f = %.1f Hz, 2f = %.1f Hz, 3f = %.1f Hz\n', f, 2*f, 3*f);
mprintf('Peak of composite signal : %.4f V\n', max(abs(s)));
mprintf('Dominant frequency       : %.1f Hz (largest amplitude component)\n', f);
