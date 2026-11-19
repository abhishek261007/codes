// =============================================================
// Program 08.1 - DPCM Encoding (single-pass, decoder-consistent)
// Experiment 9: DPCM
// Objective: Encode an oversampled sine message with Differential
//   PCM. A zero-order predictor predicts the current sample from the
//   DECODER-side reconstruction x_rec(n-1), only the prediction error
//   is quantized (Emax = 0.3, L = 16 levels, 4 bits), and the
//   reconstruction is built sample-by-sample in the SAME loop.
//   Show: message vs reconstruction, prediction error e(n) vs
//   quantized error eq(n), and report SQNR.
// =============================================================
// WHY the predictor uses x_rec (the decoder reconstruction), NOT the
// original x: the decoder at the far end never sees x. If the encoder
// predicted from x but the decoder predicts from x_rec, the two would
// drift apart after the very first mismatch. By predicting from the
// reconstruction BOTH sides compute the identical predictor from the
// identical history -> they stay perfectly in sync, with zero drift,
// no matter how coarse the quantizer is.
//
// WHY a single pass: doing prediction, quantization and reconstruction
// in one loop is the simplest way to guarantee encoder/decoder
// consistency - the encoder's "x_rec" IS the decoder's reconstruction,
// computed the same way, from the same data, in the same order. This
// is exactly what a real DPCM coder-decoder does; splitting it into
// two loops (as in dpcm-decoding.sci) just makes the two terminals
// explicit.
//
// WHY DPCM helps: for an oversampled, sample-to-sample CORRELATED
// signal, consecutive samples are close together, so the prediction
// error e(n) = x(n) - x_rec(n-1) has much smaller energy than x(n)
// itself. Quantizing that small error with the same number of bits
// gives far less relative error -> higher SQNR for free.

// ---------------- PARAMETERS ----------------
fs   = 50;                   // sampling frequency, Hz (oversampled: fs >> fm)
fm   = 2;                    // message frequency, Hz
Am   = 1;                    // message amplitude
t    = 0:1/fs:1-1/fs;        // time axis, 50 samples over [0, 1) s
N    = length(t);            // number of samples
Emax = 0.3;                  // quantization range for the error: [-Emax, +Emax]
                             // NOTE: max possible |e| = Am*2*sin(%pi*fm/fs) ~= 0.251,
                             // so Emax MUST exceed 0.251. The 0.2 value sometimes
                             // quoted for this demo clips the error and sends the
                             // reconstruction into a drift: SQNR collapses below PCM.
L    = 16;                   // quantization levels for the error
bits = log2(L);              // bits per sample (4)
// ----------------------------------------------
delta = 2*Emax/L;            // uniform step size for the error quantizer

mprintf('fs = %d Hz, fm = %d Hz, samples N = %d\n', fs, fm, N);
mprintf('Emax = %.2f, L = %d levels (%d bits), delta = %.4f\n', Emax, L, bits, delta);
mprintf('Max possible |e| = %.4f (theory 2*Am*sin(pi*fm/fs))\n', 2*Am*sin(%pi*fm/fs));

x    = Am*sin(2*%pi*fm*t);   // message, N samples
x_rec = zeros(1, N);         // decoder-side reconstruction (starts from nothing)
e_q   = zeros(1, N);         // quantized prediction error (what goes on the line)
e_raw = zeros(1, N);         // unquantized prediction error (for the plot)

// -------- Single-pass DPCM loop: predict -> quantize -> reconstruct --------
for n = 1:N
    if n == 1 then
        pred = 0;            // no history yet: predict 0 (both ends agree on this)
    else
        pred = x_rec(n-1);   // zero-order predictor FROM THE RECONSTRUCTION
    end
    e = x(n) - pred;         // prediction error
    eq = floor(e/delta + 0.5)*delta;   // round-to-nearest level
    eq = min(max(eq, -Emax), Emax);    // clip to the quantizer range (no overflow)
    x_rec(n) = pred + eq;    // reconstruction: integrate the quantized error
    e_q(n)   = eq;           // this is what the decoder receives
    e_raw(n) = e;
end

// ---------------- Key numbers ----------------
err  = x - x_rec;                            // total reconstruction error
mse  = mean(err.^2);                         // mean squared error
sqnr = 10*log10(mean(x.^2)/mse);             // DPCM SQNR in dB
disp(max(abs(e_raw)), 'Max |prediction error e| =');
disp(delta, 'Quantizer step delta =');
disp(max(abs(e_q)), 'Max |quantized error eq| (should be <= Emax) =');
disp(mse, 'Reconstruction MSE =');
disp(sqnr, 'DPCM SQNR (dB) =');
mprintf('4-bit PCM on the raw [-1,1] signal would give ~= %.2f dB (6.02*4+1.76)\n', 6.02*bits+1.76);
mprintf('Prediction gain Gp = %.2f dB (error variance reduced by this much)\n', ...
        10*log10(variance(x)/variance(e_raw)));

// ---------------- Plots ----------------
scf(0); clf();
subplot(2, 1, 1);
plot(t, x, 'b-*', 'MarkerSize', 7);   // message samples
plot(t, x_rec, 'r-o', 'MarkerSize', 5); // DPCM reconstruction overlays them
xlabel('t (s)'); ylabel('Amplitude');
title('DPCM: message (blue *) vs reconstruction (red o)');
xgrid(); legend(['message x(n)'; 'reconstruction x_rec(n)']);

subplot(2, 1, 2);
plot(t, e_raw, 'g-');                  // true prediction error
plot(t, e_q, 'k--*', 'MarkerSize', 6); // quantized error (stepped)
xlabel('t (s)'); ylabel('Error');
title('Prediction error e(n) (green) vs quantized error eq(n) (black dashed)');
xgrid(); legend(['e(n)'; 'eq(n)']);

mprintf('Observation: e(n) is a tiny fraction of x(n) - that is the whole DPCM idea.\n');
