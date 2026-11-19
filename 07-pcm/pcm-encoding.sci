// =============================================================
// Program 07.4 - PCM Encoding (samples -> level indices -> bits)
// Experiment 8: PCM
// Objective: Take the first 12 samples of a sine message, quantize
//   them at n = 4 bits (L = 16), and print a readable table: sample
//   index, amplitude, level index q, and the 4-bit binary code built
//   with a MANUAL modulo-2 loop (no dec2bin dependence).
// =============================================================
// WHY manual binary conversion: Scilab does have dec2bin, but building
// the string bit-by-bit with modulo() makes the SerDes (serializer/
// deserializer) principle visible - the ONLY thing that actually goes
// on the line is a stream of bits, MSB first. Transmitting an integer
// "q" is abstract; transmitting its bits is what a PCM link does.
// SerDes context: the encoder serializes q into n wires-worth of bits
// (0101...), the line carries them, and the decoder at the far end
// deserializes n bits back into q.

// ---------------- PARAMETERS ----------------
fs_s = 50;                   // sampling frequency, Hz
fm   = 2;                    // message frequency, Hz
t    = (0:fs_s-1)/fs_s;      // samples over [0, 1) s
m    = sin(2*%pi*fm*t);      // normalized message in [-1, 1]
xmin = -1;                   // range minimum
xmax = 1;                    // range maximum
n    = 4;                    // bits per sample
L    = 2^n;                  // 16 levels
NSAMP = 12;                  // first 12 samples only (readability)
// ----------------------------------------------
delta = (xmax - xmin)/L;

mprintf('delta = %.4f,  L = %d,  bits per sample n = %d\n\n', delta, L, n);
mprintf(' idx | amplitude |   q  | binary code\n');
mprintf('-----+-----------+------+-------------\n');

bitstream = '';              // concatenated line bits (MSB first per sample)
for k = 1:NSAMP
    xk = m(k);
    q  = floor((xk - xmin)/delta);
    q  = min(max(q, 0), L-1);             // clip to [0, L-1]

    // ---- Manual binary conversion: repeatedly divide by 2 ----
    // WHY: modulo(q,2) gives the current LSB; integer division shifts right.
    // Collect bits into a column, then flip to read MSB-first.
    bits = zeros(1, n);
    qq   = q;
    for b = n:-1:1
        bits(b) = modulo(qq, 2);             // 0 or 1
        qq = floor(qq/2);                 // shift right
    end
    code = '';
    for b = 1:n
        if bits(b) == 1 then
            code = code + '1';             // append MSB-first
        else
            code = code + '0';
        end
    end

    mprintf(' %3d |  %+.4f  | %3d  | %s\n', k, xk, q, code);
    bitstream = bitstream + code;          // 4 bits per sample on the line
    disp([k, xk, q], 'row k, amplitude, q');
end

mprintf('\nFull serialized bitstream (first %d samples), MSB first:\n', NSAMP);
mprintf('%s\n', bitstream);
mprintf('Total bits in this burst = %d bits (%d samples x %d bits)\n', length(bitstream), NSAMP, n);
disp(length(bitstream), 'Total bits in the serialized stream =');
