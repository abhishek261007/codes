// =============================================================
// Program 05.5 - SNR vs Demodulation Quality (AM envelope detector)
// Experiment 5: AM/FM with AWGN and SNR
// Objective: Generate one AM signal; add AWGN at SNR = [20, 10, 0, -5] dB;
//            demodulate each with an envelope detector (abs() then moving
//            average of length L = round(fs/fc) = 50); stack the recovered
//            messages in subplots; disp the correlation coefficient between
//            each recovered message and the original message.
// =============================================================

// SNR CONVENTION: Ps = mean(s.^2); Pn = mean(n.^2);
// SNR_dB = 10*log10(Ps/Pn);  sigma^2 = Ps / 10^(SNR_dB/10).

// ---------------- PARAMETERS ----------------
fs = 10000;                  // sampling frequency, Hz
fm = 10;                     // message frequency, Hz
Am = 1;                      // message amplitude, V
fc = 200;                    // carrier frequency, Hz
Ac = 1;                      // carrier amplitude, V
mu = 0.5;                    // AM modulation index
Tdur = 0.5;                  // total duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
L    = round(fs / fc);       // moving-average length for envelope detector = 50
snrs = [20, 10, 0, -5];      // the four test SNRs in dB
// --------------------------------------------

// One AM signal, reused for all four SNRs (same "transmitted" waveform)
m = Am * cos(2 * %pi * fm * t);
s = Ac * (1 + mu * m) .* cos(2 * %pi * fc * t);
Ps = mean(s.^2);

rand("seed", 123);           // reproducible

recovered = zeros(4, length(t));
corr_coef = zeros(1, 4);

for k = 1:4
    snr_db = snrs(k);
    sigma  = sqrt(Ps / 10^(snr_db/10));          // variance formula
    n      = grand(1, length(t), "nor", 0, sigma);   // AWGN, NOT rand()
    y      = s + n;

    // Envelope detector: rectify (abs) then low-pass via moving average.
    // WHY: the AM envelope is Ac*(1 + mu*m(t)); abs() folds the carrier,
    // the moving average kills the 2*fc ripple and keeps the message band.
    env = abs(y);
    // WHY convol: moving average = convolution of env with ones(1,L)/L.
    // 'same' style: take the first length(t) samples of the full convolution.
    r_full = convol(env, ones(1, L) / L);
    r = r_full(1:length(t));

    // Remove the DC offset (Ac plus mean of noise rectification bias) so we
    // correlate only the message-bearing part.
    r_msg = r - mean(r);
    m_c   = m - mean(m);

    // Correlation coefficient between recovered message and original message
    corr_coef(k) = sum(r_msg .* m_c) / sqrt(sum(r_msg.^2) * sum(m_c.^2));
    recovered(k, :) = r;
end

// ---------------- PLOTS ----------------
idx = t <= 0.2;              // show first 0.2 s
scf(1);
clf(1);
subplot(5,1,1);
plot(t(idx), m(idx), "b");
ylabel("Amplitude (V)");
title("Original message m(t) = Am*cos(2*pi*10*t)");
xgrid();
for k = 1:4
    subplot(5,1,k+1);
    plot(t(idx), recovered(k, idx), "r");
    ylabel("Amplitude (V)");
    title(msprintf("Envelope-detected message, SNR = %d dB (corr = %.3f)", snrs(k), corr_coef(k)));
    xgrid();
end
xlabel("Time (s)");

// ---------------- Optional bar chart of correlation ----------------
scf(2);
clf(2);
bar(snrs, corr_coef);
xlabel("SNR (dB)");
ylabel("Correlation coefficient");
title("Recovered-message correlation vs SNR (AM envelope detector)");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 5 / snr-comparison - KEY RESULTS");
mprintf("Signal power Ps            = %f\n", Ps);
mprintf("Moving-average length L    = %d  (round(fs/fc) = round(%d/%d))\n", L, fs, fc);
mprintf("Correlation of recovered vs original message:\n");
for k = 1:4
    mprintf("  SNR = %3d dB  ->  correlation = %f\n", snrs(k), corr_coef(k));
end
mprintf("Interpretation: correlation drops as SNR falls - AM envelope detection\n");
mprintf("degrades gracefully but steadily; unlike FM (with limiter + capture\n");
mprintf("effect), AM has no mechanism to reject amplitude noise.\n");
