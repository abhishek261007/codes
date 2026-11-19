// =============================================================
// Program 07.5 - PCM Decoding (bits -> level indices -> samples)
// Experiment 8: PCM
// Objective: Encode a sine into a 4-bit PCM bitstream, then run the
//   DECODER: split the stream into n-bit words, convert each back to
//   its level index, reconstruct with xmin + (q + 0.5)*delta, and
//   overlay original vs PCM-decoded staircase.
// =============================================================
// WHY decode: PCM is only complete when the RX side can recover the
// samples from raw bits. Chain: DAC-side index q -> add half-step offset
// -> output xmin + (q + 0.5)*delta.
// BIT ERRORS (comment only): a single flipped bit in bit position b
// changes q by 2^(n-b). A flip of the MSB is catastrophic (error of
// delta*8 for n = 4); a flip of the LSB is one step. Real PCM links use
// line coding, scrambling and FEC to keep BER low - here we assume a
// perfect channel.

// ---------------- PARAMETERS ----------------
fs_s = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
t    = (0:fs_s-1)/fs_s;      // samples over [0, 1) s
m    = sin(2*%pi*fm*t);      // normalized message
xmin = -1;                   // range minimum
xmax = 1;                    // range maximum
n    = 4;                    // bits per sample
L    = 2^n;                  // 16 levels
NSAMP = 25;                  // encode/decode first 25 of 50 samples
// ----------------------------------------------
delta = (xmax - xmin)/L;

// ---- TX: encode to a bitstream string ----
bitstream = '';
q_tx = zeros(1, NSAMP);
for k = 1:NSAMP
    q = floor((m(k) - xmin)/delta);
    q = min(max(q, 0), L-1);
    q_tx(k) = q;
    bits = zeros(1, n);
    qq = q;
    for b = n:-1:1
        bits(b) = modulo(qq, 2);
        qq = floor(qq/2);
    end
    code = '';
    for b = 1:n
        if bits(b) == 1 then
            code = code + '1';
        else
            code = code + '0';
        end
    end
    bitstream = bitstream + code;
end

// ---- RX: parse the bitstream back into indices ----
q_rx = zeros(1, NSAMP);
for k = 1:NSAMP
    word = part(bitstream, (k-1)*n + 1:k*n);   // extract n-bit word
    q = 0;
    for b = 1:n
        if part(word, b) == '1' then
            q = q + 2^(n-b);                    // MSB weight 2^(n-1) ... LSB 2^0
        end
    end
    q_rx(k) = q;
end

// ---- Reconstruct (half-step offset is mandatory) ----
m_dec = xmin + (q_rx + 0.5)*delta;
e = m(1:NSAMP) - m_dec;
mse = mean(e.^2);

disp(NSAMP*n,   'Total bits in this burst =');
disp(NSAMP*n/8, 'Bytes carried by this burst = (12.5 bytes, padded to 13 on a real link)');
disp(mse, 'Mean squared reconstruction error =');
disp(10*log10(mean(m(1:NSAMP).^2)/mse), 'PCM reconstruction SQNR (dB) =');
mprintf('delta = %.4f, bytes = %.1f, bits = %d\n', delta, NSAMP*n/8, NSAMP*n);

// ---------------- PLOT ----------------
clf;
scf(0);
plot(t(1:NSAMP), m(1:NSAMP), 'b-o', 'MarkerSize', 5);
plot(t(1:NSAMP), m_dec, 'r-s', 'MarkerSize', 5);
xlabel('t (s)');
ylabel('Amplitude');
title('PCM decode: original vs reconstructed (n = 4 bits)');
legend(['original m(t)', 'PCM-decoded xq(t)'], 'in_upper_right');
xgrid;
