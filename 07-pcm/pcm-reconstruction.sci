// =============================================================
// Program 07.7 - End-to-End PCM Demo (sample -> quantize -> decode)
// Experiment 8: PCM
// Objective: Run the FULL PCM chain on a sine message for n = 3, 4 and
//   8 bits: bandlimit -> sample at fs_s = 50 Hz -> quantize uniformly
//   -> (binary encode is implicit) -> decode -> reconstruct. One
//   subplot per bit depth, SQNR printed for each, plus the PCM
//   BITRATE = fs_s * n for each n.
// =============================================================
// =============================================================
//  BIG PICTURE - THE PCM CHAIN
//
//   message m(t)  --[1. SAMPLING]-->  m(k*Ts),  fs_s >= 2*fm (here 50 >> 4)
//                --[2. QUANTIZATION]-->  level index q(k) in [0, L-1], L = 2^n
//                --[3. BINARY ENCODING]-->  n bits per sample on the line
//
//   On the receive side the chain runs in reverse: bits -> q ->
//   xmin + (q + 0.5)*delta -> DAC / hold -> optional lowpass -> m_hat(t).
//
//   BITRATE: a binary PCM link carries n bits PER SAMPLE at fs_s
//   samples per second, so:
//
//        bitrate = n * fs_s   bits per second
//
//   With fs_s = 50 Hz: n = 3 -> 150 bps, n = 4 -> 200 bps, n = 8 -> 400 bps.
//   This is why PCM trades bandwidth directly against fidelity: each
//   extra bit buys ~6 dB of SQNR and costs fs_s more bits every second.
//
//   Bit depth vs quality: n = 3 (8 levels) is visibly coarse, n = 4
//   (16 levels) is decent for voice, n = 8 (256 levels) is telephony
//   grade (G.711 is 8-bit). Doubling SQNR by 6 dB costs one bit.
// =============================================================

// ---------------- PARAMETERS ----------------
fs_s = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
t    = (0:fs_s-1)/fs_s;      // 50 samples over [0, 1) s
m    = sin(2*%pi*fm*t);      // normalized message in [-1, 1]
xmin = -1;                   // range minimum
xmax = 1;                    // range maximum
n_list = [3 4 8];            // bit depths for the three cases
// ----------------------------------------------

clf;
scf(0);
for i = 1:length(n_list)
    n     = n_list(i);
    L     = 2^n;
    delta = (xmax - xmin)/L;

    // Quantize (encoder picks q; decoder maps q back to cell centre)
    q  = floor((m - xmin)/delta);
    q  = min(max(q, 0), L-1);
    mq = xmin + (q + 0.5)*delta;
    e  = m - mq;
    sqnr = 10*log10(mean(m.^2)/mean(e.^2));

    disp(n, '---------------- n (bits) =');
    disp(L, 'Levels L =');
    disp(delta, 'delta =');
    disp(sqnr, 'Measured end-to-end SQNR (dB) =');
    disp(fs_s*n, 'PCM bitrate fs_s*n (bits/s) =');
    mprintf('n = %d bits: L = %d, delta = %.4f, SQNR = %.2f dB (theory %.2f dB), bitrate = %d bps\n', ..
            n, L, delta, sqnr, 6.02*n+1.76, fs_s*n);

    subplot(3,1,i);
    plot(t, m, 'b-');                       // smooth original
    plot(t, mq, 'r-o', 'MarkerSize', 4);    // reconstructed staircase points
    xlabel('t (s)'); ylabel('Amplitude');
    title(msprintf('n = %d bits (L = %d): SQNR = %.2f dB, bitrate = %d bps', n, L, sqnr, fs_s*n));
    legend(['original m(t)', 'PCM reconstructed'], 'in_upper_right');
    xgrid;
end

mprintf('\nAt 50 Hz sampling and 8 bits, the PCM line rate is %d bits/s.\n', fs_s*8);
mprintf('Telephony sanity check: G.711 uses 8 kHz sampling -> 64000 bps.\n');
