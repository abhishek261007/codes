// square-wave.sci
// Experiment: Signal Generation
// Objective:
//   Generate an ideal square wave with sign() and then show how the
//   Fourier series converges to it. A square wave contains ONLY odd
//   harmonics:
//       square(t) = sum_{k=1..inf} (4A/pi) * (1/(2k-1)) * sin(2*pi*(2k-1)*f*t)
//   The first-3-harmonic approximation (k = 1, 2, 3 -> harmonics 1, 3, 5)
//   is plotted alongside the ideal wave to prove the series visually.

// ---------------- PARAMETERS (with units) ----------------
A   = 1;      // Amplitude (half peak-to-peak) of the square wave, in volts (V)
f   = 5;      // Fundamental frequency, in hertz (Hz)
fs  = 10000;  // Sampling frequency (samples per second, Hz). Needs to be high: ideal square wave has infinite harmonics.
dur = 0.4;    // Duration, in seconds (s). Two periods of a 5 Hz signal.

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur;

// ---------------- IDEAL SQUARE WAVE ----------------
// sign() returns +1 when sin > 0, -1 when sin < 0, and 0 exactly at
// the zero crossings (a single sample, harmless for plotting).
y_ideal = A * sign(sin(2 * %pi * f * t));

// ---------------- FOURIER SERIES APPROXIMATION ----------------
// Only odd harmonics, each with amplitude 4A/(pi*(2k-1)).
// k = 1 -> 1st harmonic, k = 2 -> 3rd harmonic, k = 3 -> 5th harmonic.
y_approx = zeros(1, length(t));
for k = 1:3
    n = 2*k - 1;                          // harmonic number (1, 3, 5)
    y_approx = y_approx + (4 * A / %pi) * (1 / n) * sin(2 * %pi * n * f * t);
end

// Fundamental (1st harmonic) amplitude of the approximation:
fundamental_amplitude = 4 * A / %pi;

// ---------------- PLOTTING ----------------
scf(0); clf(0);
subplot(2, 1, 1);
plot(t, y_ideal, 'b-', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('Amplitude (V)');
title('Ideal square wave: y = sign(sin(2*pi*f*t))');
xgrid();
legend('ideal square wave', 'location', 'northeast');

subplot(2, 1, 2);
plot(t, y_ideal, 'b-', 'LineWidth', 1.5);
plot(t, y_approx, 'r--', 'LineWidth', 2);
xlabel('Time t (s)');
ylabel('Amplitude (V)');
title('Ideal square wave vs first-3-harmonic (1st, 3rd, 5th) Fourier approximation');
xgrid();
legend('ideal', 'Fourier approx (3 harmonics)', 'location', 'northeast');

// ---------------- RESULTS ----------------
mprintf('\n==== Square Wave Results ====\n');
mprintf('Amplitude A                          : %.4f V\n', A);
mprintf('Fundamental frequency f              : %.4f Hz\n', f);
mprintf('Fundamental amplitude of approximation: 4A/pi = %.4f V\n', fundamental_amplitude);
mprintf('Peak of 3-harmonic approximation     : %.4f V\n', max(abs(y_approx)));
mprintf('Peak of ideal square wave            : %.4f V\n', max(abs(y_ideal)));
mprintf('Note: ideal square wave has odd harmonics only: 5, 15, 25, ... Hz\n');
