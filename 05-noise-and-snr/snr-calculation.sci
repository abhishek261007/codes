// =============================================================
// Program 05.4 - SNR Calculation (function-based script)
// Experiment 5: AM/FM with AWGN and SNR
// Objective: Write a calc_snr(sig, noise) function, add AWGN to an
//            AM signal at four TARGET SNRs (20, 10, 5, 0 dB) using the
//            variance formula, measure each with calc_snr, and disp
//            target vs measured SNR. Plot the four noisy signals.
// =============================================================

// SNR CONVENTION (used throughout this experiment):
//   signal power Ps = mean(s.^2);  noise power Pn = mean(n.^2);
//   SNR_dB = 10*log10(Ps/Pn);
//   given target SNR_dB:  sigma^2 = Ps / 10^(SNR_dB/10);
//   sigma = sqrt(Ps * 10^(-SNR_dB/10)).

// ---- FUNCTION: calc_snr ----
// WHY a function: SNR measurement should not be copy-pasted; a tested
// helper keeps every measurement consistent.
function [snr_db] = calc_snr(sig, noise)
    snr_db = 10 * log10(mean(sig.^2) / mean(noise.^2));
endfunction

// ---------------- PARAMETERS ----------------
fs = 10000;                  // sampling frequency, Hz
fm = 10;                     // message frequency, Hz
Am = 1;                      // message amplitude, V
fc = 200;                    // carrier frequency, Hz
Ac = 1;                      // carrier amplitude, V
mu = 0.5;                    // AM modulation index
Tdur = 0.5;                  // total duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
target_snrs = [20, 10, 5, 0];   // the four TARGET SNRs in dB
// --------------------------------------------

// (a) Build the AM signal
m = Am * cos(2 * %pi * fm * t);
s = Ac * (1 + mu * m) .* cos(2 * %pi * fc * t);
Ps = mean(s.^2);

// (b) + (c) Add AWGN at each target SNR and measure it
rand("seed", 123);           // reproducible noise for every target
y        = zeros(4, length(t));
meas_snr = zeros(1, 4);
mprintf("\n Experiment 5 / snr-calculation - TARGET vs MEASURED SNR\n");
mprintf("--------------------------------------------------\n");
for k = 1:4
    snr_target = target_snrs(k);
    sigma2 = Ps / 10^(snr_target/10);       // variance formula
    sigma  = sqrt(sigma2);
    nk = grand(1, length(t), "nor", 0, sigma);   // AWGN, NOT rand()
    yk = s + nk;
    meas_snr(k) = calc_snr(s, nk);          // measured SNR in dB
    y(k, :) = yk;
    mprintf("Target = %3d dB | Measured = %8.4f dB | delta = %7.4f dB | Pn = %f\n", ...
            snr_target, meas_snr(k), meas_snr(k) - snr_target, mean(nk.^2));
end
mprintf("--------------------------------------------------\n");
mprintf("Small deltas (< ~0.1 dB) come from the finite number of noise samples\n");
mprintf("(5000 samples); with infinite samples measured would equal target exactly.\n");

// (d) Plot the four noisy signals (first 0.2 s)
idx = t <= 0.2;
scf(1);
clf(1);
for k = 1:4
    subplot(4,1,k);
    plot(t(idx), y(k, idx), "r");
    ylabel("Amplitude (V)");
    title(msprintf("Noisy AM at SNR = %d dB (measured %.2f dB)", target_snrs(k), meas_snr(k)));
    xgrid();
end
xlabel("Time (s)");

// ---------------- KEY RESULTS ----------------
disp("Experiment 5 / snr-calculation - KEY RESULTS");
mprintf("Signal power Ps = %f\n", Ps);
for k = 1:4
    mprintf("SNR target %3d dB -> measured %f dB\n", target_snrs(k), meas_snr(k));
end
