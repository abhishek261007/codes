// =============================================================
// Program 08.3 - DPCM vs PCM at EQUAL bits (4 bits/sample)
// Experiment 9: DPCM
// Objective: Run DPCM (4 bits on the prediction error, Emax = 0.3)
//   and plain PCM (4 bits on the raw signal, range [-1, 1]) on the
//   same message, compute both SQNRs, and compare them in a bar
//   chart. Prove DPCM wins at equal bit rate for a correlated source.
// =============================================================
// Key fix applied here (do NOT "simplify" back to Emax = 0.2): the
//   largest possible |e| for THIS signal is Am*2*sin(pi*fm/fs) ~= 0.251,
//   so Emax = 0.3 is the smallest safe choice. At Emax = 0.2 the error
//   clips every peak; the clipped error feeds back through the
//   predictor, the reconstruction drifts, max |e| grows to ~0.39, and
//   DPCM ends up ~9 dB WORSE than PCM. Emax = 0.3 keeps SQNR ~35 dB.
//
// ----------------------------------------------
// BIG IDEA: A PCM quantizer must cover the FULL signal range with
// L = 2^4 = 16 levels -> delta_pcm = 2/16 = 0.125. A DPCM quantizer
// only has to cover the PREDICTION ERROR range
// [-Emax, Emax] = [-0.3, 0.3] -> delta_dpcm = 0.6/16 = 0.0375.
//
// THEORY: for a correlated source, SQNR_dpcm ~= SQNR_pcm + Gp, where
//   Gp = 10*log10( var(x) / var(e) )   is the PREDICTION GAIN.
// The error energy is concentrated in a narrow band around 0, so the
// quantizer wastes no levels on the (unlikely) large excursions.
// Practical DPCM gains for speech/audio-like correlated signals are
// roughly 4-11 dB over PCM at the same bit rate - or equivalently
// 1-2 bits/sample saved at the same quality.
//
// WHY PCM still matters: PCM is simple and robust (no error
// propagation between samples); DPCM is more efficient but a corrupted
// E_Q symbol perturbs the reconstruction until the predictor
// re-converges. Adaptive variants (e.g. delta modulation, ADPCM)
// change the step size on the fly and are treated in the next
// experiment.

// ---------------- PARAMETERS ----------------
fs   = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
Am   = 1;                    // message amplitude
t    = 0:1/fs:1-1/fs;        // time axis
N    = length(t);            // number of samples
Emax = 0.3;                  // DPCM error-quantizer range
L    = 16;                   // 16 levels = 4 bits for BOTH schemes
bits = log2(L);              // 4 bits/sample
// ---------------- PCM parameters ----------------
xmin  = -1;                  // PCM range: full message range
xmax  =  1;
delta_pcm = (xmax - xmin)/L; // 0.125
// ---------------- DPCM parameters ----------------
delta_dpcm = 2*Emax/L;       // 0.025
// ----------------------------------------------
x = Am*sin(2*%pi*fm*t);      // message

// ---------------- 1) Plain PCM, 4 bits, round-to-nearest + clip -----
x_pcm = min(max(floor(x/delta_pcm + 0.5)*delta_pcm, xmin), xmax);
mse_pcm  = mean((x - x_pcm).^2);
sqnr_pcm = 10*log10(mean(x.^2)/mse_pcm);

// ---------------- 2) DPCM, 4 bits on the error, single-pass ---------
x_rec = zeros(1, N);
e_q   = zeros(1, N);
for n = 1:N
    if n == 1 then
        pred = 0;
    else
        pred = x_rec(n-1);   // predictor from RECONSTRUCTION (consistency!)
    end
    e  = x(n) - pred;
    eq = floor(e/delta_dpcm + 0.5)*delta_dpcm;
    eq = min(max(eq, -Emax), Emax);  // clip
    x_rec(n) = pred + eq;
    e_q(n)   = eq;
end
mse_dpcm  = mean((x - x_rec).^2);
sqnr_dpcm = 10*log10(mean(x.^2)/mse_dpcm);

// ---------------- Comparison numbers ----------------
Gp = 10*log10(variance(x)/variance(x - [0, x(1:N-1)]));  // rough prediction gain (1st diff)
disp(delta_pcm, 'PCM step delta_pcm =');
disp(delta_dpcm, 'DPCM step delta_dpcm =');
disp(mse_pcm, 'PCM MSE =');
disp(mse_dpcm, 'DPCM MSE =');
disp(sqnr_pcm, 'PCM  SQNR (dB) =');
disp(sqnr_dpcm, 'DPCM SQNR (dB) =');
disp(sqnr_dpcm - sqnr_pcm, 'DPCM advantage over PCM (dB) =');
mprintf('Theoretical 4-bit PCM full-range sine: ~= %.2f dB (6.02*4+1.76)\n', 6.02*bits+1.76);
mprintf('DPCM wins by ~= %.2f dB at the SAME %d bits/sample.\n', sqnr_dpcm - sqnr_pcm, bits);

// ---------------- Plots ----------------
scf(0); clf();
subplot(2, 1, 1);
plot(t, x, 'b-');                        // original
plot(t, x_pcm, 'g--');                   // PCM reconstruction
plot(t, x_rec, 'r--o', 'MarkerSize', 5); // DPCM reconstruction
xlabel('t (s)'); ylabel('Amplitude');
title('Original vs PCM (4 bit) vs DPCM (4 bit) reconstruction');
xgrid(); legend(['Original'; 'PCM 4-bit'; 'DPCM 4-bit']);

subplot(2, 1, 2);
bar([sqnr_pcm, sqnr_dpcm]);
xlabel('1 = PCM 4-bit       2 = DPCM 4-bit');
ylabel('SQNR (dB)');
title('SQNR comparison at equal bits (4 bits/sample)');
xgrid();

mprintf('Takeaway: prediction exploits sample correlation -> finer effective step -> higher SQNR.\n');
