// =============================================================
// Program 05.3 - FM Signal Corrupted by AWGN (SNR = 10 dB)
// Experiment 5: AM/FM with AWGN and SNR
// Objective: Build the FM signal by phase integration, add AWGN at
//            SNR = 10 dB, plot clean FM / noise / noisy FM, and disp
//            the measured powers and SNR.
// =============================================================

// ---------------- PARAMETERS ----------------
fs = 10000;                  // sampling frequency, Hz
fm = 10;                     // message frequency, Hz
Am = 1;                      // message amplitude, V
fc = 200;                    // carrier frequency, Hz
Ac = 1;                      // carrier amplitude (constant envelope), V
beta = 2;                    // FM modulation index
kf   = 20;                   // frequency sensitivity, Hz/V  (beta = kf*Am/fm = 20/10 = 2)
Tdur = 0.5;                  // total duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
SNR_dB = 10;                 // target SNR in dB
// --------------------------------------------

// Message m(t) = Am*cos(2*pi*fm*t)
m = Am * cos(2 * %pi * fm * t);

// WHY phase integration: s(t) = Ac*cos(2*pi*fc*t + phi(t)) with
// phi(t) = 2*pi*kf*integral(m(tau))dtau.  Numerically, cumsum(m)/fs is the
// running integral. Writing cos(2*pi*(fc+kf*m)*t) is WRONG.
phi = 2 * %pi * kf * cumsum(m) / fs;
s   = Ac * cos(2 * %pi * fc * t + phi);

// SNR CONVENTION: Ps = mean(s.^2) (for Ac = 1 sinusoid, Ps ~ 0.5).
// sigma^2 = Ps / 10^(SNR_dB/10).
Ps = mean(s.^2);
sigma2 = Ps / 10^(SNR_dB/10);
sigma  = sqrt(sigma2);

rand("seed", 123);                      // reproducible noise
n = grand(1, length(t), "nor", 0, sigma);   // AWGN, NOT rand()

y = s + n;                              // noisy FM signal

Pn = mean(n.^2);
SNR_meas_dB = 10 * log10(Ps / Pn);

// ---------------- PLOTS (first 0.2 s for readability) ----------------
idx = t <= 0.2;

scf(1);
clf(1);
subplot(3,1,1);
plot(t(idx), s(idx), "b");
ylabel("Amplitude (V)");
title("Clean FM signal s(t), fc = 200 Hz, beta = 2, kf = 20 Hz/V (constant envelope)");
xgrid();
subplot(3,1,2);
plot(t(idx), n(idx), "g");
ylabel("Amplitude (V)");
title("AWGN n(t), SNR target = 10 dB");
xgrid();
subplot(3,1,3);
plot(t(idx), y(idx), "r");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("Noisy received FM y(t) = s(t) + n(t) (noise pushes amplitude peaks, phase intact-ish)");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 5 / noisy-fm-signal - KEY RESULTS");
mprintf("Signal power Ps          = %f   (Ac^2/2 = %f for a sinusoid)\n", Ps, Ac^2/2);
mprintf("Noise variance sigma^2   = %f   (set from target SNR = %d dB)\n", sigma2, SNR_dB);
mprintf("Measured noise power Pn  = %f\n", Pn);
mprintf("Measured SNR             = %f dB   (target = %d dB)\n", SNR_meas_dB, SNR_dB);
mprintf("FM is CONSTANT-ENVELOPE: noise adds amplitude variations, but an FM\n");
mprintf("demodulator (limiter + discriminator) discards amplitude info, so FM\n");
mprintf("resists amplitude noise much better than AM at the same SNR.\n");
