// =============================================================
// Program 08 - FFT of Multiple Tones
// Experiment 2: Sampling and FFT
// Objective: Analyse x = 1.0*sin(2*pi*50*t) + 0.5*sin(2*pi*120*t)
// sampled at fs = 1000 Hz with N = 1000 (both tones complete an
// integer number of cycles in the window, so there is no leakage).
// Read both peak frequencies and amplitudes from the spectrum.
// =============================================================

// ---------------- PARAMETERS ----------------
fs  = 1000;           // sampling frequency, Hz
N   = 1000;           // samples = 1 s of data (50 and 120 full cycles: integer!)
fA  = 50;             // tone A frequency, Hz, amplitude 1.0 V
fB  = 120;            // tone B frequency, Hz, amplitude 0.5 V
AA  = 1.0;            // tone A amplitude, V
AB  = 0.5;            // tone B amplitude, V
// --------------------------------------------

t = (0:N-1) / fs;
x = AA * sin(2 * %pi * fA * t) + AB * sin(2 * %pi * fB * t);

// FFT normalisation: f = (0:N/2)*fs/N ; single-sided A = 2*|X|/N
X  = fft(x);
X1 = 2 * abs(X(1:N/2+1)) / N;
X1(1)     = abs(X(1)) / N;      // DC bin: not doubled
X1(N/2+1) = abs(X(N/2+1)) / N;  // Nyquist bin: not doubled
f  = (0:N/2) * fs / N;

// Find the two largest peaks (they are in bins 50 and 120)
function [f_pk, A_pk] = peak_at(f, X1, f_target)
    k = round(f_target * N / fs) + 1;   // nearest bin, +1 for 1-based indexing
    f_pk = f(k);
    A_pk = X1(k);
endfunction
[fA_pk, AA_pk] = peak_at(f, X1, fA);
[fB_pk, AB_pk] = peak_at(f, X1, fB);

// ---------------- PLOT ----------------
scf(1);
clf(1);
plot(f, X1, "b");
xlabel("Frequency (Hz)");
ylabel("Single-Sided Magnitude");
title("Single-Sided Spectrum: 1.0 V @ 50 Hz + 0.5 V @ 120 Hz");
xgrid();

// ---------------- KEY NUMBERS ----------------
mprintf("\n--- Multiple tones FFT: key values ---\n");
mprintf("Sampling frequency fs       = %.2f Hz\n", fs);
mprintf("Nyquist frequency fs/2      = %.2f Hz\n", fs / 2);
mprintf("Frequency resolution df     = fs/N = %.2f Hz\n", fs / N);
mprintf("Tone A: expected %.2f Hz / %.2f V -> measured %.2f Hz / %.4f V\n", fA, AA, fA_pk, AA_pk);
mprintf("Tone B: expected %.2f Hz / %.2f V -> measured %.2f Hz / %.4f V\n", fB, AB, fB_pk, AB_pk);
mprintf("DC bin magnitude            = %.4f\n", abs(X(1)) / N);

// WHY IT MATTERS:
// N = 1000 with fs = 1000 gives df = 1 Hz, and both tones sit on
// exact bins, so the spectrum is two clean spikes. If N were not an
// integer number of cycles (say N = 1024 with f0 = 50 Hz), energy
// would LEAK into neighbouring bins and the measured amplitude at
// the peak bin would read lower than 1.0 / 0.5 V. Remedies: pick N
// so cycles are integer, or apply a window (Hann/Hamming) - at the
// cost of widening the peak.
