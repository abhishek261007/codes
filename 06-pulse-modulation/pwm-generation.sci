// =============================================================
// Program 06.5 - PWM Generation (pulse-width modulation)
// Experiment 6: Pulse Modulation
// Objective: Build a PWM waveform where the pulse WIDTH (not the
//            amplitude) varies linearly with the message amplitude:
//            tau_k = tau0*(1 + m_mod*m(t_s(k))/max|m|)
//            tau0 = 0.008 s mid width, m_mod = 0.8 (80% depth).
// =============================================================
// KEY IDEA: PWM keeps the pulse amplitude CONSTANT (A = 1 V) and encodes
// information in the WIDTH. Width must satisfy 0 < tau_k < Ts always:
//   tau_min = tau0*(1 - m_mod) = 0.0016 s  > 0
//   tau_max = tau0*(1 + m_mod) = 0.0144 s  < Ts = 0.02 s
// WHY constant amplitude helps: PWM passes through nonlinear/clipping
// channels better than PAM because width (a timing quantity) is what
// carries the information, and the receiver can just use hard
// thresholding. Amplitude noise does not corrupt the width directly.

// ---------------- PARAMETERS ----------------
fs   = 20000;                // analysis sampling frequency, Hz
Tdur = 0.1;                  // window duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
fm   = 5;                    // message frequency, Hz
m    = sin(2*%pi*fm*t);      // message signal m(t)
mmax = max(abs(m));          // normalization for modulation depth
fs_s = 50;                   // pulse repetition rate, Hz
Ts   = 1/fs_s;               // sampling period, s
tau0 = 0.008;                // mid (unmodulated) pulse width, s
m_mod = 0.8;                 // modulation depth (80%)
A    = 1;                    // CONSTANT pulse amplitude, V
t_s  = 0:Ts:max(t);          // sampling instants
N    = length(t);
// --------------------------------------------

y = zeros(1, N);             // PWM output vector
tau_k = zeros(1, length(t_s));
for k = 1:length(t_s)
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);
    // Width encodes the message; amplitude stays A
    tau_k(k) = tau0 * (1 + m_mod * ms / mmax);
    // Integer index range of t inside [t_s(k), t_s(k)+tau_k)
    i1 = round(t_s(k)*fs) + 1;
    i2 = floor((t_s(k)+tau_k(k))*fs);
    for i = i1:i2
        y(i) = A;            // CONSTANT amplitude pulse
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
xlabel('t (s)'); ylabel('y_PWM(t) (V)')
title('PWM waveform - width varies with message, amplitude constant (A = 1 V)')
xgrid()

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / pwm-generation - KEY NUMBERS')
disp('Number of pulses: ' + string(length(t_s)))
disp('tau0 = ' + string(tau0) + ' s, m_mod = ' + string(m_mod))
disp('Min pulse width tau_min = ' + string(min(tau_k)) + ' s')
disp('Max pulse width tau_max = ' + string(max(tau_k)) + ' s (must be < Ts = ' + string(Ts) + ' s)')
disp('Constant amplitude A = ' + string(A) + ' V - only width carries information')
