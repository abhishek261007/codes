// =============================================================
// Program 06.7 - PPM Generation (pulse-position modulation)
// Experiment 6: Pulse Modulation
// Objective: Build a PPM waveform. All pulses have FIXED width
//            tau_p = 0.001 s and FIXED amplitude A = 1 V; only the
//            POSITION of each pulse within its period shifts:
//            d_k = D*m(t_s(k))/max|m|,  D = 0.008 s.
// =============================================================
// KEY IDEA: PPM encodes information in the pulse POSITION. Compared to
// PWM it uses much less energy (pulses are very short) and is best in
// noise - the receiver only needs to time edges precisely. Constraint:
// pulses must not overlap, so |d_k| + tau_p < Ts:
//   max position  = D + tau_p = 0.009 s  < Ts = 0.02 s  OK
//   min position  = -D        = -0.008 s > -(Ts - tau_p) OK
// Pulse k is placed at [t_s(k) + d_k, t_s(k) + d_k + tau_p).

// ---------------- PARAMETERS ----------------
fs   = 20000;                // analysis sampling frequency, Hz
Tdur = 0.1;                  // window duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
fm   = 5;                    // message frequency, Hz
m    = sin(2*%pi*fm*t);      // message signal m(t)
mmax = max(abs(m));          // normalization
fs_s = 50;                   // pulse repetition rate, Hz
Ts   = 1/fs_s;               // sampling period, s
tau_p = 0.001;               // FIXED pulse width, s
D    = 0.008;                // max position deviation, s (< Ts - tau_p)
A    = 1;                    // FIXED pulse amplitude, V
t_s  = 0:Ts:max(t);          // sampling instants
N    = length(t);
// --------------------------------------------

y = zeros(1, N);             // PPM output vector
d_k = zeros(1, length(t_s));
for k = 1:length(t_s)
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);
    // Position deviation encodes the message (linear law, bipolar)
    d_k(k) = D * ms / mmax;
    t_start = t_s(k) + d_k(k);
    // Integer index range of t inside [t_start, t_start+tau_p)
    i1 = round(t_start*fs) + 1;
    i2 = floor((t_start+tau_p)*fs);
    for i = i1:i2
        y(i) = A;            // FIXED amplitude pulse at shifted position
    end
end
m_samp = m(round(t_s*fs) + 1);

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t_s, m_samp, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r')
xlabel('t (s)'); ylabel('m(t) (V)')
title('Message m(t) with sampling instants (fs_s = 50 Hz)')
xgrid(); legend(['m(t)', 'samples'], 'location', 'northeast')

subplot(2,1,2)
plot(t, y, 'r-', 'LineWidth', 2)
xlabel('t (s)'); ylabel('y_PPM(t) (V)')
title('PPM waveform - fixed width (1 ms) & amplitude, position shifts with m(t)')
xgrid()

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / ppm-generation - KEY NUMBERS')
disp('Number of pulses: ' + string(length(t_s)))
disp('Fixed pulse width tau_p = ' + string(tau_p) + ' s, amplitude A = ' + string(A) + ' V')
disp('Position delay range: [' + string(min(d_k)) + ', ' + string(max(d_k)) + '] s')
disp('Max excursion D + tau_p = ' + string(D + tau_p) + ' s < Ts = ' + string(Ts) + ' s -> no overlap')
