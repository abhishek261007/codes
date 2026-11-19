// =============================================================
// Program 07 - FFT of a Single Tone
// Experiment 2: Sampling and FFT
// Objective: Compute the single-sided spectrum of a pure 50 Hz
// sine sampled at fs = 1000 Hz with N = 1000 points, using the
// normalisation f = (0:N/2)*fs/N and single-sided amplitude
// 2*|fft(x)|/N. Verify the peak lands on 50 Hz with amplitude ~1.
// =============================================================

// ---------------- PARAMETERS ----------------
fs = 1000;            // sampling frequency, Hz
N  = 1000;            // number of samples = 1 second of data
f0 = 50;              // tone frequency, Hz (bin 50 - an integer number of cycles)
Am = 1;               // tone amplitude, V
// --------------------------------------------

t = (0:N-1) / fs;
x = Am * sin(2 * %pi * f0 * t);

// FFT normalisation rule:
//   frequency axis  f = (0:N/2) * fs / N        (N/2+1 points, 0..fs/2)
//   single-sided    A = 2*|fft(x)|/N            (DC and Nyquist bins NOT doubled)
X  = fft(x);
X1 = 2 * abs(X(1:N/2+1)) / N;    // single-sided spectrum, 0..fs/2
// DC and Nyquist bins carry half weight; fix them explicitly:
X1(1)      = abs(X(1)) / N;      // DC bin: no doubling
X1(N/2+1)  = abs(X(N/2+1)) / N;  // Nyquist bin: no doubling
f  = (0:N/2) * fs / N;

// Peak detection
[Amax, kmax] = max(X1);
f_peak = f(kmax);

// ---------------- PLOT ----------------
scf(1);
clf(1);
plot(f, X1, "b");
xlabel("Frequency (Hz)");
ylabel("Single-Sided Magnitude");
title("Single-Sided Spectrum of sin(2*pi*50*t), fs = 1000 Hz, N = 1000");
xgrid();

// ---------------- KEY NUMBERS ----------------
mprintf("\n--- Single tone FFT: key values ---\n");
mprintf("Sampling frequency fs       = %.2f Hz\n", fs);
mprintf("Nyquist frequency fs/2      = %.2f Hz\n", fs / 2);
mprintf("FFT size N                  = %d\n", N);
mprintf("Frequency resolution df     = fs/N = %.2f Hz\n", fs / N);
mprintf("Peak bin frequency          = %.2f Hz (bin %d)\n", f_peak, kmax - 1);
mprintf("Measured amplitude at peak  = %.4f (expected %.2f)\n", Amax, Am);
mprintf("DC bin magnitude            = %.4f\n", abs(X(1)) / N);

// WHY IT MATTERS:
// Two things make this spectrum clean: (1) the tone frequency is an
// exact integer multiple of df = fs/N = 1 Hz (50 cycles fit in the
// 1 s window), so leakage is zero and energy lives in one bin;
// (2) the 2/N scaling recovers the true amplitude. Forgetting the
// 2/N factor underestimates every non-DC amplitude by a factor of 2.
