// =============================================================
// Program 05.2 - AM Signal Corrupted by AWGN (SNR = 10 dB)
// Experiment 5: AM/FM with AWGN and SNR
// Objective: Build the DSB-LC AM signal, add AWGN at SNR = 10 dB,
//            plot clean AM / noise / noisy AM (first 0.2 s shown),
//            and disp the measured signal power, noise power and SNR.
// =============================================================

// ---------------- PARAMETERS ----------------
fs = 10000;                  // sampling frequency, Hz
fm = 10;                     // message frequency, Hz
Am = 1;                      // message amplitude, V
fc = 200;                    // carrier frequency, Hz
Ac = 1;                      // carrier amplitude, V
mu = 0.5;                    // AM modulation index (0 < mu < 1, no over-modulation)
Tdur = 0.5;                  // total duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
SNR_dB = 10;                 // target SNR in dB
// --------------------------------------------

// Message and AM signal:  s(t) = Ac*(1 + mu*cos(2*pi*fm*t))*cos(2*pi*fc*t)
m = Am * cos(2 * %pi * fm * t);
s = Ac * (1 + mu * m) .* cos(2 * %pi * fc * t);

// SNR CONVENTION: Ps = mean(s.^2); target SNR_dB => noise variance
// sigma^2 = Ps / 10^(SNR_dB/10).  Always measure SNR from mean-square,
// never from peak amplitude.
Ps = mean(s.^2);
sigma2 = Ps / 10^(SNR_dB/10);     // required noise variance
sigma  = sqrt(sigma2);            // required noise std dev

rand("seed", 123);                // reproducible noise
n = grand(1, length(t), "nor", 0, sigma);   // AWGN, NOT rand()

y = s + n;                        // noisy AM signal (additive noise)

// Measured powers and SNR (should match the 10 dB target closely)
Pn = mean(n.^2);
SNR_meas_dB = 10 * log10(Ps / Pn);

// ---------------- PLOTS (first 0.2 s for readability) ----------------
idx = t <= 0.2;                   // only show the first 0.2 s, else cycles blur

scf(1);
clf(1);
subplot(3,1,1);
plot(t(idx), s(idx), "b");
ylabel("Amplitude (V)");
title("Clean AM signal s(t), fc = 200 Hz, fm = 10 Hz, mu = 0.5");
xgrid();
subplot(3,1,2);
plot(t(idx), n(idx), "g");
ylabel("Amplitude (V)");
title("AWGN n(t), sigma^2 = Ps / 10^(SNR_dB/10), SNR target = 10 dB");
xgrid();
subplot(3,1,3);
plot(t(idx), y(idx), "r");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("Noisy received AM y(t) = s(t) + n(t) (envelope still visible at 10 dB)");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 5 / noisy-am-signal - KEY RESULTS");
mprintf("Signal power Ps          = %f\n", Ps);
mprintf("Noise variance sigma^2   = %f   (set from target SNR = %d dB)\n", sigma2, SNR_dB);
mprintf("Measured noise power Pn  = %f\n", Pn);
mprintf("Measured SNR             = %f dB   (target = %d dB)\n", SNR_meas_dB, SNR_dB);
mprintf("Envelope detection at 10 dB SNR: the message envelope Ac*(1+mu*m) is\n");
mprintf("still visible above the noise; a simple abs() + lowpass detector works,\n");
mprintf("though the recovered message will carry visible noise ripple.\n");
