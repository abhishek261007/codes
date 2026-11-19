// =============================================================
// Program 04.4 - Wideband FM and Bessel sidebands
// Experiment 4: FM Transmission and Reception
// Objective: Generate FM with beta = 5, plot the time signal and
//            its instantaneous frequency, show the full FFT from
//            0 to fs/2 with the Bessel sidebands at fc +/- n*fm,
//            annotate the fm spacing and disp the measured peak
//            frequencies (expect around 150..250 Hz).
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
beta = 5;              // wideband modulation index
df   = beta * fm;      // deviation, Hz (df = 50 Hz)
kf   = df / Am;        // kf = 50 Hz/V
Tdur = 0.4;            // 0.4 s -> 4 message cycles, FFT bin spacing = 2.5 Hz
N    = round(fs * Tdur);
// --------------------------------------------

t = (0:N-1) / fs;
m = Am * cos(2 * %pi * fm * t);
phase = 2 * %pi * fc * t + 2 * %pi * kf * cumsum(m) / fs;   // phase integration
s     = Ac * cos(phase);
fi    = fc + kf * m;

// Single-sided amplitude spectrum (2/N scaling, DC/Nyquist not doubled)
S   = fft(s);
P   = abs(S(1:floor(N/2)+1));
if modulo(N, 2) == 0 then
    P(2:$-1) = 2 * P(2:$-1) / N;
    P(1) = P(1) / N;
    P($) = P($) / N;
else
    P(2:$) = 2 * P(2:$) / N;
    P(1) = P(1) / N;
end
f = (0:floor(N/2)) * fs / N;

// Find local maxima, then keep the largest ones as "peaks"
loc = find(P(2:$-1) > P(1:$-2) & P(2:$-1) >= P(3:$)) + 1;
if length(loc) == 0 then
    loc = 1;
end
[sorted_mag, order] = gsort(P(loc), "g", "d");
n_keep = min(8, length(loc));
peak_bins = loc(order(1:n_keep));
peak_freqs = (peak_bins - 1) * fs / N;
[peak_freqs_sorted, idx_sort] = gsort(peak_freqs, "g", "i");

scf(1);
clf(1);
subplot(3,1,1);
plot(t, s, "r");
ylabel("Amplitude (V)");
title("Wideband FM, beta = 5: notice the period changes within each message cycle");
xgrid();
subplot(3,1,2);
plot(t, fi, "g");
ylabel("f_i(t) (Hz)");
title("Instantaneous frequency: fc +/- df = 200 +/- 50 Hz");
xgrid();
subplot(3,1,3);
plot(f, P);
xlabel("Frequency (Hz)");
ylabel("Magnitude (V)");
title("FM spectrum, beta = 5: sideband pairs at fc +/- n*fm, n = 0,1,2,... spacing = 10 Hz");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 4 / wideband-fm - KEY RESULTS");
mprintf("beta                       = %f\n", beta);
mprintf("df = beta*fm               = %f Hz\n", df);
mprintf("kf                         = %f Hz/V\n", kf);
mprintf("Carson BW = 2*(beta+1)*fm  = %f Hz\n", 2*(beta+1)*fm);
disp("Measured peak frequencies (Hz) and magnitudes (V):");
for k = 1:n_keep
    idx = peak_bins(k);
    mprintf("  peak at %f Hz   magnitude %f V\n", (idx-1)*fs/N, P(idx));
end
mprintf("Expected sideband locations: 200 +/- n*10 Hz, i.e. 140,150,...,260 Hz\n");
mprintf("Significant Bessel sidebands for beta = 5 extend to about n = 7 (J_n(5) drops off beyond that).\n");
mprintf("Sideband spacing equals fm = %f Hz. Number of significant pairs ~ beta + 1 = %d.\n", fm, ceil(beta)+1);
