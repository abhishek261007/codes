// =============================================================
// Program 10 - Frequency Spectrum of AM, DSB-C and DSB-SC
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Single-sided FFT magnitude (2/N scaling, DC/Nyquist
//            not doubled) of (a) the message, (b) conventional AM
//            with mu = 0.5, (c) DSB-SC. Verify carrier at 200 Hz
//            and sidebands at fc +/- fm = 190 / 210 Hz. Show that
//            DSB-SC has NO spectral line at 200 Hz.
// =============================================================

// ---------------- PARAMETERS ----------------
fs_spec = 10000;       // spectral analysis sampling rate, Hz
N       = 10000;       // FFT length -> 1 s window, resolution fs_spec/N = 1 Hz
fm      = 10;          // message frequency, Hz   (100 complete cycles: integer, no leakage)
fc      = 200;         // carrier frequency, Hz   (2000 complete cycles: integer)
Ac      = 1;           // carrier amplitude, V
Am      = 1;           // message amplitude, V
mu      = 0.5;         // modulation index (conventional AM only)
// --------------------------------------------

t   = (0:N-1) / fs_spec;
mn  = cos(2 * %pi * fm * t);
m   = Am * mn;
sAM = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t);   // conventional AM / DSB-C
sSC = Ac * m .* cos(2 * %pi * fc * t);               // DSB-SC

// Single-sided amplitude spectrum.
// WHY: for a sine of amplitude A, |fft| peaks at N*A/2, hence 2*|fft|/N.
// DC and the Nyquist bin are NOT doubled (they have no mirror image).
function Xs = single_sided(x)
    Nn = length(x);
    X  = 2 * abs(fft(x)) / Nn;
    Xs = X(1:Nn/2 + 1);
    Xs(1) = Xs(1) / 2;             // DC: undo doubling
    Xs($) = Xs($) / 2;             // Nyquist bin (even N): undo doubling
endfunction

f       = (0:N/2) * fs_spec / N;   // 0..5000 Hz axis
X_m     = single_sided(m);
X_am    = single_sided(sAM);
X_sc    = single_sided(sSC);

// Peak detection: with integer cycles the spectrum is essentially impulses,
// so any bin above 1% of the global max is a true line.
function [freqs, amps] = peak_lines(Xs, f)
    thr   = max(Xs) * 0.01;
    idx   = find(Xs > thr);
    freqs = f(idx);
    amps  = Xs(idx);
endfunction

[f_m,  a_m]  = peak_lines(X_m,  f);
[f_am, a_am] = peak_lines(X_am, f);
[f_sc, a_sc] = peak_lines(X_sc, f);

scf(1);
clf(1);
subplot(3,1,1);
plot(f, X_m, "b");
ylabel("Magnitude (V)");
title("Spectrum of message m(t): single line at 10 Hz, amplitude 1");
xgrid();
subplot(3,1,2);
plot(f, X_am, "r");
ylabel("Magnitude (V)");
title("Conventional AM / DSB-C (mu = 0.5): carrier 200 Hz + sidebands 190/210 Hz");
xstring(195, max(X_am)*0.75, "190 Hz");
xstring(197, max(X_am)*1.05, "200 Hz (carrier)");
xstring(207, max(X_am)*0.30, "210 Hz");
xgrid();
subplot(3,1,3);
plot(f, X_sc, "m");
xlabel("Frequency (Hz)");
ylabel("Magnitude (V)");
title("DSB-SC: ONLY sidebands at 190/210 Hz, NO carrier line at 200 Hz");
xstring(188, max(X_sc)*0.55, "190 Hz");
xstring(206, max(X_sc)*0.55, "210 Hz");
xgrid();

mprintf("Experiment 3 / am-frequency-spectrum - KEY RESULTS\n");
mprintf("fs_spec = %d Hz, N = %d, bin spacing = %f Hz\n", fs_spec, N, fs_spec/N);
mprintf("Message peaks   : "); for i = 1:length(f_m),  mprintf("%d Hz (%.3f V)  ", f_m(i),  a_m(i));  end; mprintf("\n");
mprintf("AM (mu=0.5)     : "); for i = 1:length(f_am), mprintf("%d Hz (%.3f V)  ", f_am(i), a_am(i)); end; mprintf("\n");
mprintf("DSB-SC          : "); for i = 1:length(f_sc), mprintf("%d Hz (%.3f V)  ", f_sc(i), a_sc(i)); end; mprintf("\n");
mprintf("Carrier amplitude Ac  = %f V (AM carrier line should read ~1.0)\n", Ac);
mprintf("Carrier bin (200 Hz) AM    = %.4f V\n", X_am(201));   // bin k = f/(fs/N), k=200 -> index 201
mprintf("Carrier bin (200 Hz) DSB-SC= %.4f V  (~0: carrier suppressed!)\n", X_sc(201));
mprintf("Theory: AM carrier = Ac = 1.0, each sideband = mu*Ac/2 = %.2f V\n", mu*Ac/2);
mprintf("Theory: DSB-SC sidebands = Ac*Am/2 = %.2f V each, NO 200 Hz line\n", Ac*Am/2);
