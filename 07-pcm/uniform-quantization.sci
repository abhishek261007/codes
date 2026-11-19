// =============================================================
// Program 07.2 - Uniform Quantization: SQNR vs Bit Depth
// Experiment 8: PCM
// Objective: Quantize the same sine wave with n = 2, 3, 4, 8 bits and
//   tabulate the measured SQNR (dB) against the theoretical
//   6.02*n + 1.76 dB rule; draw a bar chart with the theory overlaid.
// =============================================================
// WHY a systematic study: the 6.02 dB/bit rule is the single most quoted
// number in PCM design - you trade BIT RATE against FIDELITY. One extra
// bit halves the step, quarters the error power, gains ~6 dB.
// WHY it breaks at 2 bits: the derivation assumes the error is uniformly
// distributed in [-delta/2, delta/2] and independent of the signal, which
// needs many levels. At L = 4 the sine peaks almost always land on the
// same few levels and the error is strongly signal-correlated, so the
// formula is only approximate there.

// ---------------- PARAMETERS ----------------
fs_s = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
t    = (0:fs_s-1)/fs_s;      // 50 samples over [0, 1) s
m    = sin(2*%pi*fm*t);      // message in [-1, 1] (full-scale sine)
xmin = -1;                   // range minimum
xmax = 1;                    // range maximum
n_list = [2 3 4 8];          // bit depths to study
// ----------------------------------------------

// ---- Function: uniform mid-tread quantize at n bits, return SQNR in dB ----
function sqnr = sqnr_uniform(m, n, xmin, xmax)
    L     = 2^n;
    delta = (xmax - xmin)/L;
    q     = floor((m - xmin)/delta);
    q     = min(max(q, 0), L-1);               // clip to [0, L-1]
    mq    = xmin + (q + 0.5)*delta;
    e     = m - mq;
    sqnr  = 10*log10(mean(m.^2)/mean(e.^2));
endfunction

sqnr_meas = zeros(1, length(n_list));
sqnr_theo = 6.02*n_list + 1.76;              // theoretical rule, per n
for i = 1:length(n_list)
    sqnr_meas(i) = sqnr_uniform(m, n_list(i), xmin, xmax);
end

// ---------------- TABLE ----------------
mprintf('\n n   L    delta      SQNR_meas(dB)  SQNR_theo(dB)\n');
for i = 1:length(n_list)
    Li = 2^n_list(i);
    di = (xmax - xmin)/Li;
    mprintf('%2d  %3d   %.4f      %10.2f      %10.2f\n', n_list(i), Li, di, sqnr_meas(i), sqnr_theo(i));
end
for i = 1:length(n_list)
    disp([n_list(i), 2^n_list(i), sqnr_meas(i), sqnr_theo(i)], 'n, L, SQNR_meas, SQNR_theo for row');
end
mprintf('\nNote: at n = 2 bits the flat-error/many-levels assumption fails,\n');
mprintf('so the measured SQNR departs from 6.02*n+1.76 = %.2f dB.\n', 6.02*2+1.76);

// ---------------- PLOT ----------------
clf;
scf(0);
bar(n_list, sqnr_meas);                      // bar chart of measured SQNR vs n
plot(n_list, sqnr_theo, 'r--d', 'MarkerSize', 8);   // theory overlay (dashed)
xlabel('Bits per sample n');
ylabel('SQNR (dB)');
title('Uniform quantization: measured SQNR vs 6.02n + 1.76 rule');
legend(['measured SQNR', 'theory 6.02n + 1.76'], 'in_upper_left');
xgrid;
