// =============================================================
// Program 02 - Ideal (Impulse-Train) Sampling Demo
// Experiment 2: Sampling and FFT
// Objective: Show ideal sampling as multiplication of the message
// by a comb of impulses, xs(t) = m(t) .* comb(t). Visualise the
// impulse train (as very narrow pulses for display), the sample
// values, and the spectrum with its copies at k*fs_s.
// =============================================================

// ---------------- PARAMETERS ----------------
fm     = 10;          // message frequency, Hz
Am     = 1;           // message amplitude, V
fs_s   = 40;          // sampling frequency, Hz
Ts     = 1 / fs_s;    // sampling period, s
fs_hi  = 10000;       // fine time grid for plotting, Hz
T      = 0.2;         // total simulation time, s
pw     = 0.02;        // display pulse width as fraction of Ts (visualisation only)
// --------------------------------------------

// Time axis and message
t = 0:1/fs_hi:T;
m = Am * cos(2 * %pi * fm * t);

// Comb of impulses. TRUE impulses have zero width and infinite
// height, so they cannot be drawn or FFT'd directly. We use very
// narrow pulses (2% of Ts) purely to VISUALISE where the impulses
// live. The sample values themselves are taken exactly at n*Ts.
comb_viz = bool2s(modulo(t, Ts) < pw * Ts);
x_viz    = m .* comb_viz;    // narrow-pulse version (for display/FFT)

// Exact sample values
t_s = 0:Ts:T;
m_s = Am * cos(2 * %pi * fm * t_s);

// ---------------- PLOT 1: original, comb, samples ----------------
scf(1);
clf(1);
subplot(3,1,1);
plot(t, m, "k");
ylabel("Amplitude (V)");
title("Original message m(t)");
xgrid();
subplot(3,1,2);
plot(t, comb_viz, "b");
ylabel("comb(t)");
title("Impulse train (drawn as narrow pulses, 1 spike every Ts)");
xgrid();
subplot(3,1,3);
plot(t_s, m_s, "r+");
plot(t_s, m_s, "b-");
xlabel("Time (s)");
ylabel("Amplitude (V)");
legend("samples m(nTs)");
title("xs(t) = m(t) .* comb(t): impulse-weighted sample values");
xgrid();

// ---------------- PLOT 2: spectrum with copies at k*fs_s ----------------
// Ideal sampling in the frequency domain:
//   Xs(f) = (1/Ts) * sum_k X(f - k*fs_s)
// i.e. the message spectrum is COPIED to every integer multiple of
// the sampling frequency. The FFT below (of the narrow-pulse
// visualisation) shows exactly those copies, weighted by a sinc-like
// roll-off from the 2% pulse width.
N  = length(t);
X  = abs(fft(x_viz)) / N;         // two-sided magnitude (unnormalised shape)
fs_disp = fs_hi;
f  = (0:N/2) * fs_disp / N;
X1 = X(1:N/2+1);                  // keep 0..fs/2 half

scf(2);
clf(2);
plot(f, X1, "b");
xlabel("Frequency (Hz)");
ylabel("|Xs(f)| (normalised)");
title("Spectrum of sampled signal: copies centred at k * fs_s = k * 40 Hz");
xgrid();

// ---------------- KEY NUMBERS ----------------
mprintf("\n--- Ideal sampling: key values ---\n");
mprintf("Message frequency fm        = %.2f Hz\n", fm);
mprintf("Sampling frequency fs_s     = %.2f Hz\n", fs_s);
mprintf("Nyquist frequency fs_s/2    = %.2f Hz\n", fs_s / 2);
mprintf("Sampling period Ts          = %.4f s\n", Ts);
mprintf("Number of samples in %.2f s = %d\n", T, length(t_s));
mprintf("Spectrum copies centred at  : 0, %.0f, %.0f, %.0f, ... Hz\n", fs_s, 2*fs_s, 3*fs_s);
mprintf("Baseband tone appears at    : %.0f Hz and at %.0f +/- %.0f Hz, ...\n", fm, fs_s, fm);
disp("First 5 sample values m(nTs):");
disp(m_s(1:5));

// WHY IT MATTERS:
// Ideal sampling produces EXACT copies of the message spectrum at
// every k*fs_s with no distortion of the baseband copy - provided
// fs_s >= 2*fm. This is the sampling theorem's starting point.
// Practical samplers (natural / flat-top) only approximate this;
// their spectra carry extra sinc-shaped envelopes, which is why
// real systems still need an anti-alias filter before sampling.
