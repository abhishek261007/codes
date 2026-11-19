// ============================================================
// Practice Program: signal-multiplication.sci
// Difficulty: Intermediate
// Topic: Signal transformations (multiplication / modulation)
// -----------------------------------------------------------
// PROBLEM STATEMENT: Multiply a 5 Hz message by a 100 Hz carrier; find the fc+fm and fc-fm spectral peaks via FFT.
// SOLUTION: implemented below — read top-to-bottom with the PARAMETERS block first.
// ============================================================

// ---------------- PARAMETERS ----------------
Am = 1.0;          // message amplitude, volts
fm = 5;            // message frequency, Hz
Ac = 1.0;          // carrier amplitude, volts
fc = 100;          // carrier frequency, Hz
fs = 2000;         // sampling frequency, Hz
dt = 1 / fs;       // sample spacing, seconds
t  = 0:dt:1;       // 1 s observation window
N  = length(t);    // number of samples (power of 2 not required for fft)
// -------------------------------------------

// --- 1. Message and carrier ---
m_t = Am * cos(2 * %pi * fm * t);
c_t = Ac * cos(2 * %pi * fc * t);

// --- 2. Multiply: product of cosines ---
// WHY: cos(a)cos(b) = 0.5*[cos(a-b) + cos(a+b)], so the product
//      contains only fc-fm = 95 Hz and fc+fm = 105 Hz (DSB-SC).
y = m_t .* c_t;

// --- 3. FFT magnitude spectrum (single-sided) ---
Y = fft(y);
mag = abs(Y) / N;              // normalise so peaks read as amplitudes
half = floor(N / 2);           // keep the positive-frequency half only
mag_ss = 2 * mag(1:half+1);    // double the one-sided amplitudes
freqs = (0:half) * fs / N;     // frequency axis in Hz

// --- 4. Read off the two sideband amplitudes at fc-fm and fc+fm ---
// WHY: instead of searching, we look up the bins nearest the expected
//      sideband frequencies; their heights should equal Am*Ac/2.
i_lo = 1 + round((fc - fm) * N / fs);   // bin for fc-fm = 95 Hz
i_hi = 1 + round((fc + fm) * N / fs);   // bin for fc+fm = 105 Hz
mprintf("Peak at fc-fm = %d Hz: magnitude = %f\n", fc - fm, mag_ss(i_lo));
mprintf("Peak at fc+fm = %d Hz: magnitude = %f\n", fc + fm, mag_ss(i_hi));
mprintf("Theory: each sideband amplitude = Am*Ac/2 = %f\n", Am * Ac / 2);

// --- 5. Plots: time domain and spectrum ---
clf;
subplot(2, 1, 1);
plot(t(1:200), y(1:200), "b-");   // first 0.1 s for readability
xlabel("Time (s)"); ylabel("Amplitude (V)");
title("Product m(t) * c(t) = cos(2pi*5t)cos(2pi*100t)"); xgrid;
subplot(2, 1, 2);
plot(freqs, mag_ss, "r-");
xlabel("Frequency (Hz)"); ylabel("Magnitude");
title("Single-sided FFT magnitude: peaks at 95 Hz and 105 Hz"); xgrid;

disp("Signal multiplication complete.");
