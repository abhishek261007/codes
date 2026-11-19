// =============================================================
// Program 08.2 - DPCM Decoding (encode and decode in TWO loops)
// Experiment 9: DPCM
// Objective: Mimic two terminals. Loop 1 (encoder, TX) runs the
//   single-pass DPCM coder and emits the quantized-error stream E_Q.
//   Loop 2 (decoder, RX) sees ONLY E_Q - never x - and integrates it
//   with the same zero-order predictor to rebuild the message.
//   Verify the decoded signal matches the encoder's reconstruction
//   EXACTLY (bit-true, zero drift).
// =============================================================
// WHY two loops: a real link transmits only E_Q; the receiver has no
// access to the original message. Forcing the decoder to work only
// from E_Q proves the scheme is self-consistent. A decoder that used
// the original x (or linear-interpolated between transmitted samples)
// would be cheating - and would break the moment the link is real.
//
// WHY no drift: both sides compute pred(n) = x_hat(n-1) from the SAME
// reconstructed history. Any quantization error made at sample n-1 is
// already folded into x_hat(n-1), so the encoder and decoder make the
// SAME prediction and stay in sync forever - the error never
// accumulates beyond what the quantizer itself introduces.
//
// WHAT THE DECODER NEEDS on the wire: the E_Q stream (4 bits/sample
// here) plus the shared knowledge of Emax, L and the predictor. That
// is the entire side information.

// ---------------- PARAMETERS ----------------
fs   = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
Am   = 1;                    // message amplitude
t    = 0:1/fs:1-1/fs;        // time axis
N    = length(t);            // number of samples
Emax = 0.3;                  // error quantizer range, [-Emax, +Emax]
                             // must exceed max |e| ~= 0.251 (see dpcm-encoding.sci)
L    = 16;                   // error quantizer levels (4 bits)
// ----------------------------------------------
delta = 2*Emax/L;            // uniform step size

x    = Am*sin(2*%pi*fm*t);   // message (TX side only!)
E_Q  = zeros(1, N);          // quantized-error stream - what goes on the line
x_rec = zeros(1, N);         // encoder's internal reconstruction (TX side)

// ============ LOOP 1: ENCODER (transmitter) ====================
// Single pass: predict -> quantize -> reconstruct, exactly as in
// dpcm-encoding.sci. Only E_Q leaves the encoder.
for n = 1:N
    if n == 1 then
        pred = 0;            // agreed starting condition: no history
    else
        pred = x_rec(n-1);   // zero-order predictor from reconstruction
    end
    e  = x(n) - pred;
    eq = floor(e/delta + 0.5)*delta;   // round to nearest level
    eq = min(max(eq, -Emax), Emax);    // clip
    x_rec(n) = pred + eq;
    E_Q(n)   = eq;           // transmit this (4 bits)
end
mprintf('Encoder done. Transmitting E_Q stream of %d symbols x %d bits = %d bits total.\n', ...
        N, log2(L), N*log2(L));

// ============ LOOP 2: DECODER (receiver) =======================
// The decoder NEVER sees x. It integrates the received stream:
//   x_hat(n) = x_hat(n-1) + E_Q(n),   x_hat(1) = E_Q(1)  (pred(1) = 0)
x_hat = zeros(1, N);
for n = 1:N
    if n == 1 then
        pred = 0;            // SAME agreed starting condition as encoder
    else
        pred = x_hat(n-1);   // SAME predictor, SAME reconstructed history
    end
    x_hat(n) = pred + E_Q(n);
end

// ---------------- Verification ----------------
diff_xe = max(abs(x_rec - x_hat));   // encoder reconstruction vs decoder output
mse     = mean((x - x_hat).^2);      // distortion seen by the user
sqnr    = 10*log10(mean(x.^2)/mse);
disp(diff_xe, 'Max |x_rec - x_hat| (encoder vs decoder, must be 0) =');
disp(mse, 'Decoded MSE =');
disp(sqnr, 'Decoded SQNR (dB) =');
if diff_xe < 1e-12 then
    disp('PASS: encoder and decoder are bit-true in sync - zero drift.');
else
    disp('FAIL: mismatch between encoder and decoder!');
end

// ---------------- Plots ----------------
scf(0); clf();
subplot(2, 1, 1);
plot(t, x, 'b-');                       // original message
plot(t, x_hat, 'r--o', 'MarkerSize', 5); // decoded message
xlabel('t (s)'); ylabel('Amplitude');
title('DPCM decoding: original (blue) vs decoded (red dashed)');
xgrid(); legend(['original x(n)'; 'decoded x_hat(n)']);

subplot(2, 1, 2);
plot(t, x - x_hat, 'm-*', 'MarkerSize', 6);
xlabel('t (s)'); ylabel('Error');
title('End-to-end reconstruction error x(n) - x_hat(n)');
xgrid();

mprintf('Note: decoder needed ONLY the E_Q stream + shared (Emax, L, predictor).\n');
