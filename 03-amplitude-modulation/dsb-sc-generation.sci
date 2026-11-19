// =============================================================
// Program 06 - DSB-SC Generation
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Generate a Double Sideband Suppressed Carrier signal
//            s(t) = Ac*m(t)*cos(2*%pi*fc*t) (NO (1+..) term, no
//            carrier line in the spectrum). Show that |s(t)| folds
//            at every message zero crossing, ruling out envelope
//            detection. Synchronous demodulation is mandatory.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude scaling, V
Am   = 1;              // message amplitude, V
mu   = 0.5;            // NOT used for DSB-SC (no carrier term) - kept for reference
Tdur = 0.4;            // seconds
N    = round(fs * Tdur);
// --------------------------------------------

t = (0:N-1) / fs;
m = Am * cos(2 * %pi * fm * t);
c = Ac * cos(2 * %pi * fc * t);
s = Ac * m .* cos(2 * %pi * fc * t);   // DSB-SC: pure product, NO DC offset
envfold = abs(s);                      // what an envelope detector would see

// WHY: s(t) = Ac*cos(wm t)*cos(wc t) = Ac/2 * [cos((wc+wm)t) + cos((wc-wm)t)]
//      Two sidebands only, NO term at fc, and phase reverses every time
//      m(t) crosses zero. Envelope |s| follows |m(t)| -> full-wave folded,
//      not a scaled copy of m(t).

scf(1);
clf(1);
subplot(3,1,1);
plot(t, m, "b");
ylabel("m(t) (V)");
title("Message m(t) = Am cos(2*pi*fm*t)");
xgrid();
subplot(3,1,2);
plot(t, c, "c");
ylabel("c(t) (V)");
title("Carrier c(t) = Ac cos(2*pi*fc*t) - NOT transmitted in DSB-SC");
xgrid();
subplot(3,1,3);
plot(t, s, "r", t, envfold, "k--", t, -envfold, "k--");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("DSB-SC s(t) with |s(t)| overlay: folds at every message zero crossing");
legend("s(t)", "|s(t)| fold", "-|s(t)|");
xgrid();

// Zero crossings of the message in the window (fm*Tdur = 4 cycles -> 8 crossings)
m_sign = sign(m);
zc = sum(abs(diff(m_sign)) > 1);
disp("Experiment 3 / dsb-sc-generation - KEY RESULTS");
mprintf("Signal type              = DSB-SC (suppressed carrier)\n");
mprintf("Carrier amplitude Ac     = %f V (scaling only; NO carrier energy sent)\n", Ac);
mprintf("s(t) expansion           = Ac/2 * [cos(2*pi*(fc+fm)*t) + cos(2*pi*(fc-fm)*t)]\n");
mprintf("Sideband amplitudes      = %f V each (Ac*Am/2)\n", Ac*Am/2);
mprintf("Message zero crossings   = %d in %f s (|s| folds at each one)\n", zc, Tdur);
mprintf("Envelope of |s(t)|       = |Ac*m(t)| -> DISTORTS the message shape\n");
mprintf("Demodulation             = Synchronous (product) detector REQUIRED\n");
