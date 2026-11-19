// =============================================================
// Program 01 - Natural Sampling
// Experiment 2: Sampling and FFT
// Objective: See how a rectangular pulse train (natural /
// sample-and-hold style) sampling process multiplies a message
// by pulses whose amplitude follows the message DURING the pulse.
// We also mark the instantaneous sample values and compare the
// result against the original message.
// =============================================================

// ---------------- PARAMETERS ----------------
fm     = 10;          // message frequency, Hz
Am     = 1;           // message amplitude, V
fs_s   = 40;          // sampling frequency, Hz
Ts     = 1 / fs_s;    // sampling period, s
duty   = 0.3;         // pulse duty cycle (width = 0.3 * Ts)
fs_hi  = 10000;       // high-resolution time grid, Hz (for plotting)
T      = 0.2;         // total simulation time, s
// --------------------------------------------

// Time axis (fine grid) and the pure message
t  = 0:1/fs_hi:T;
m  = Am * cos(2 * %pi * fm * t);

// Pulse train: 1 during the first 'duty' fraction of every Ts,
// 0 otherwise. modulo(t, Ts) resets the phase every sampling period.
pulse = bool2s(modulo(t, Ts) < duty * Ts);

// Natural sampling = message x pulse train.
// WHY: the message is NOT held flat; the top of each pulse still
// wiggles and follows m(t) across the whole pulse width.
x_nat = m .* pulse;

// Instantaneous sample values (one per sampling instant).
// True 'natural' pulses follow m(t), so the effective sample value
// at the pulse centre is approximately m(n*Ts); we mark m(n*Ts)
// as the proportional sample level for comparison.
t_s  = 0:Ts:T;
m_s  = Am * cos(2 * %pi * fm * t_s);

// ---------------- PLOT 1: message + pulses + result ----------------
scf(1);
clf(1);
subplot(3,1,1);
plot(t, m, "k");
ylabel("Amplitude (V)");
title("Original message m(t) = cos(2*pi*10*t)");
xgrid();
subplot(3,1,2);
plot(t, pulse, "b");
ylabel("Pulse (0/1)");
title("Sampling pulse train (fs_s = 40 Hz, duty = 0.3)");
xgrid();
subplot(3,1,3);
plot(t, m, "k--", t, x_nat, "b");
xlabel("Time (s)");
ylabel("Amplitude (V)");
legend("original m(t)", "naturally sampled");
title("Natural (pulse) sampling of the message");
xgrid();

// ---------------- PLOT 2: stem-style sample values ----------------
scf(2);
clf(2);
plot(t, m, "k--");
plot(t_s, m_s, "r+");
plot(t_s, m_s, "b-");
xlabel("Time (s)");
ylabel("Amplitude (V)");
legend("original m(t)", "sample values m(nTs)");
title("Sample instants (markers) vs original message");
xgrid();

// ---------------- KEY NUMBERS ----------------
mprintf("\n--- Natural sampling: key values ---\n");
mprintf("Message frequency fm       = %.2f Hz\n", fm);
mprintf("Sampling frequency fs_s    = %.2f Hz\n", fs_s);
mprintf("Nyquist frequency fs_s/2   = %.2f Hz\n", fs_s / 2);
mprintf("Sampling period Ts         = %.4f s\n", Ts);
mprintf("Pulse width                = %.4f s (%.0f%% duty)\n", duty * Ts, 100 * duty);
mprintf("Number of samples in %.2f s = %d\n", T, length(t_s));
disp("First 5 sample values m(nTs):");
disp(m_s(1:5));

// WHY IT MATTERS:
// NATURAL sampling: the pulse top is NOT flat - it tracks m(t)
// across the pulse width, so the spectrum contains sinc-shaped
// copies of m(f) at k*fs_s with NO sharp aperture distortion.
// FLAT-TOP (sample-and-hold) sampling: the top of each pulse is
// held at the value m(n*Ts) for the whole pulse width; this IS
// affected by aperture distortion (a sinc roll-off) but is easier
// to reconstruct with a hold circuit. Both differ from IDEAL
// (impulse) sampling, where samples have zero width.
// Natural sampling sits between the two: finite width, but the
// pulse top still follows the message, so no aperture error.
