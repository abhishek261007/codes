// =============================================================
// Program 04.3 - Narrowband FM vs AM spectrum
// Experiment 4: FM Transmission and Reception
// Objective: For beta = 0.2 (narrowband), compare the FFT magnitude
//            of NBFM with that of conventional AM (mu = 0.2) around
//            the carrier. Both show a carrier plus two tiny side-
//            bands; disp the first-sideband amplitude (~ Ac*beta/2).
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
beta = 0.2;            // NBFM modulation index (beta << 1)
df   = beta * fm;      // NBFM deviation, Hz (df = 2 Hz)
kf   = df / Am;        // kf = 2 Hz/V
mu   = 0.2;            // AM modulation index (same small value, for comparison)
Tdur = 0.4;            // 0.4 s -> 4 message cycles, FFT bin spacing = 2.5 Hz
N    = round(fs * Tdur);
// --------------------------------------------

t = (0:N-1) / fs;
m = Am * cos(2 * %pi * fm * t);

// NBFM via the correct phase-integration method
phase_nbfm = 2 * %pi * fc * t + 2 * %pi * kf * cumsum(m) / fs;
s_nbfm     = Ac * cos(phase_nbfm);

// Conventional AM with mu = 0.2 (for a like-for-like comparison)
s_am = Ac * (1 + mu * cos(2 * %pi * fm * t)) .* cos(2 * %pi * fc * t);

// WHY: single-sided amplitude spectrum. Raw |FFT| is scaled by 2/N so a
// sinusoid of amplitude A reads as A; DC and Nyquist are NOT doubled.
function P = single_sided_mag(x)
    S = fft(x);
    L = length(x);
    P = abs(S(1:floor(L/2)+1));
    if modulo(L, 2) == 0 then
        P(2:$-1) = 2 * P(2:$-1) / L;
        P(1) = P(1) / L;
        P($) = P($) / L;   // Nyquist bin, not doubled
    else
        P(2:$) = 2 * P(2:$) / L;
        P(1) = P(1) / L;
    end
endfunction

P_nbfm = single_sided_mag(s_nbfm);
P_am   = single_sided_mag(s_am);
f      = (0:floor(N/2)) * fs / N;

// Zoom window around the carrier
f_lo = fc - 60;
f_hi = fc + 60;
win  = find(f >= f_lo & f <= f_hi);

// Sideband bin indices (fm = 10 Hz is an exact multiple of the 2.5 Hz bin)
bin_fc   = round(fc / (fs / N)) + 1;    // Scilab is 1-based
bin_low  = round((fc - fm) / (fs / N)) + 1;
bin_high = round((fc + fm) / (fs / N)) + 1;

scf(1);
clf(1);
subplot(2,1,1);
plot(f(win), P_nbfm(win), "b-o");
ylabel("Magnitude (V)");
title("NBFM spectrum, beta = 0.2: carrier + two tiny sidebands (BW ~ 2*fm)");
xgrid();
subplot(2,1,2);
plot(f(win), P_am(win), "r-o");
xlabel("Frequency (Hz)");
ylabel("Magnitude (V)");
title("AM spectrum, mu = 0.2: same shape - carrier + two sidebands");
xgrid();

// ---------------- KEY RESULTS ----------------
sideband_nbfm = P_nbfm(bin_low);             // should be ~ Ac*beta/2
sideband_nbfm2 = P_nbfm(bin_high);
sideband_am   = P_am(bin_low);               // should be ~ mu*Ac/2
carrier_nbfm  = P_nbfm(bin_fc);
disp("Experiment 4 / narrowband-fm - KEY RESULTS");
mprintf("beta                         = %f\n", beta);
mprintf("df = beta*fm                 = %f Hz\n", df);
mprintf("NBFM first sideband (meas)   = %f V  (expected Ac*beta/2 = %f V)\n", sideband_nbfm, Ac*beta/2);
mprintf("NBFM first sideband high     = %f V\n", sideband_nbfm2);
mprintf("NBFM carrier bin             = %f V  (expected ~ Ac = %f V)\n", carrier_nbfm, Ac);
mprintf("AM  first sideband (meas)    = %f V  (expected mu*Ac/2   = %f V)\n", sideband_am, mu*Ac/2);
mprintf("NBFM BW ~ 2*fm = %f Hz, just like AM. True FM character appears only for beta >= ~0.5.\n", 2*fm);
