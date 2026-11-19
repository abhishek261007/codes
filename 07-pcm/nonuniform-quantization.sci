// =============================================================
// Program 07.3 - Non-Uniform Quantization: mu-Law Companding
// Experiment 8: PCM
// Objective: Compress a SMALL-amplitude sine (A = 0.2) with mu-law
//   (mu = 255), quantize uniformly at n = 4 bits in the COMPRESSED
//   domain, expand back, and compare its reconstruction SNR against a
//   plain uniform 4-bit quantizer on the same signal.
// =============================================================
// WHY: uniform quantizers waste levels on large amplitudes and starve
// small ones - bad for speech, whose RMS is far below full scale.
// mu-law COMPANDING (COMPress + exPAND) applies a compressive nonlinearity
// F(x) before uniform quantization and the inverse after decoding.
//   F(x)    = sign(x) * log(1 + mu*|x|) / log(1 + mu)     (compression)
//   F^-1(y) = sign(y) * ( (1 + mu)^|y| - 1 ) / mu          (expansion)
// WHY mu = 255: ITU-T G.711 (North-American PCM) standard value; it gives
//   a wide dynamic range and a near-logarithmic segment slope. The
//   compression threshold is |x| = 1/mu ~ 0.0039 below which the curve is
//   almost linear (steepest slope at 0) - small signals get the finest
//   effective step.
// WHY small amplitude: uniform 4-bit throwing levels at a signal that
// only uses 20% of range wastes most levels; mu-law re-allocates them.

// ---------------- PARAMETERS ----------------
fs_s = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
t    = (0:fs_s-1)/fs_s;      // samples over [0, 1) s
A    = 0.2;                  // SMALL amplitude - mu-law's home turf
m    = A*sin(2*%pi*fm*t);    // small-signal message
n    = 4;                    // bits per sample
L    = 2^n;                  // 16 levels
xmin = -1;                   // companding operates on the NORMALIZED range
xmax = 1;
mu   = 255;                  // mu-law parameter (G.711)
// ----------------------------------------------

delta = (xmax - xmin)/L;     // step in the COMPRESSED domain
disp(mu, 'mu-law parameter mu =');
mprintf('Compression threshold 1/mu = %.5f (below this F(x) is ~ linear)\n', 1/mu);
mprintf('Max compressed slope at x = 0: F''(0) = mu/log(1+mu) = %.2f\n', mu/log(1+mu));
mprintf('Step delta in compressed domain = %.4f\n', delta);

// ---- mu-law compress / expand (elementwise, sign-aware) ----
function y = mulaw_compress(x, mu)
    y = sign(x) .* log(1 + mu*abs(x)) ./ log(1 + mu);
endfunction
function x = mulaw_expand(y, mu)
    x = sign(y) .* ((1 + mu).^abs(y) - 1) ./ mu;
endfunction

// ---- Path 1: mu-law compand -> uniform quantize -> expand ----
mc   = mulaw_compress(m, mu);
q_c  = floor((mc - xmin)/delta);
q_c  = min(max(q_c, 0), L-1);              // clip indices to [0, L-1]
mcq  = xmin + (q_c + 0.5)*delta;           // cell-centre reconstruction
m_mulaw = mulaw_expand(mcq, mu);           // expand back to signal domain

// ---- Path 2: plain uniform quantize of the small sine (same n) ----
q_u  = floor((m - xmin)/delta);
q_u  = min(max(q_u, 0), L-1);
m_uni  = xmin + (q_u + 0.5)*delta;         // NOTE: off- centre vs true uniform mid-tread
// fair "uniform over [-1,1]" comparison - same clipping treatment

snr_mulaw = 10*log10(mean(m.^2)/mean((m - m_mulaw).^2));
snr_uni   = 10*log10(mean(m.^2)/mean((m - m_uni).^2));
disp(snr_mulaw, 'Reconstruction SNR mu-law 4-bit (dB) =');
disp(snr_uni,   'Reconstruction SNR uniform 4-bit (dB) =');
disp(snr_mulaw - snr_uni, 'Improvement from companding (dB) =');

// ---------------- PLOT ----------------
clf;
scf(0);
plot(t, m, 'b-o', 'MarkerSize', 4);                    // original
plot(t, m_mulaw, 'r-s', 'MarkerSize', 4);              // mu-law reconstruction
plot(t, m_uni, 'g-^', 'MarkerSize', 4);                // uniform reconstruction
xlabel('t (s)');
ylabel('Amplitude');
title('mu-law (mu = 255) vs uniform 4-bit quantization of a 0.2-amplitude sine');
legend(['original m(t) (A = 0.2)', 'mu-law reconstructed', 'uniform reconstructed'], 'in_upper_right');
xgrid;
