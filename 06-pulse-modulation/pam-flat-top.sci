// =============================================================
// Program 06.3 - Flat-Top PAM (sample-and-hold)
// Experiment 6: Pulse Modulation
// Objective: Build FLAT-TOP PAM - each pulse is held flat at the
//            sample value taken at the START of the pulse (classic
//            sample-and-hold / flat-top sampling). Note the aperture
//            (droop) distortion it introduces versus natural sampling.
// =============================================================
// FLAT-TOP vs NATURAL (do not confuse the two):
//   natural  : pulse top = slice of m(t)         -> no aperture distortion
//   flat-top : pulse top = m(t_s(k)), held flat  -> aperture distortion
// WHY: holding a value constant over tau is equivalent to convolving
// the impulse-sampled message with a rectangular pulse of width tau.
// In the frequency domain that multiplies the spectrum by
// sinc(f*tau) (aperture effect). For fm*tau << 1 the droop is small;
// here fm*tau = 5*0.005 = 0.025, so sin(pi*0.025)/(pi*0.025) ~ 0.9995,
// almost negligible - but it grows with wider tau or higher fm.

// ---------------- PARAMETERS ----------------
fs   = 20000;                // analysis sampling frequency, Hz
Tdur = 0.1;                  // window duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
fm   = 5;                    // message frequency, Hz
m    = sin(2*%pi*fm*t);      // message signal m(t)
fs_s = 50;                   // pulse repetition rate, Hz
Ts   = 1/fs_s;               // sampling period, s
tau  = 0.005;                // pulse width, s (25% duty)
t_s  = 0:Ts:max(t);          // sampling instants
N    = length(t);
// --------------------------------------------

y = zeros(1, N);             // flat-top PAM output vector
for k = 1:length(t_s)
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);      // value sampled at the START of the pulse
    // Integer index range of t inside [t_s(k), t_s(k)+tau)
    i1 = round(t_s(k)*fs) + 1;
    i2 = floor((t_s(k)+tau)*fs);
    for i = i1:i2
        y(i) = ms;           // HOLD the sample value flat over tau
    end
end
m_samp = m(round(t_s*fs) + 1);

// WHY show the droop numerically: compare pulse top against the
// message at the pulse END - that difference is the aperture error.
i_end1 = round((t_s(1)+tau)*fs);
droop1 = m(i_end1) - m_samp(1);

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t_s, m_samp, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r')
xlabel('t (s)'); ylabel('m(t) (V)')
title('Message m(t) with sampling instants (fs_s = 50 Hz)')
xgrid(); legend(['m(t)', 'samples'], 'location', 'northeast')

subplot(2,1,2)
plot(t, y, 'm-', 'LineWidth', 2)
plot(t_s, m_samp, 'ro', 'MarkerSize', 7, 'MarkerFaceColor', 'r')
xlabel('t (s)'); ylabel('y_flat(t) (V)')
title('Flat-top PAM (sample-and-hold), amplitude frozen at pulse start')
xgrid(); legend(['flat-top PAM', 'sample values'], 'location', 'northeast')

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / pam-flat-top - KEY NUMBERS')
disp('Number of samples: ' + string(length(t_s)))
disp('fm*tau = ' + string(fm*tau) + ' (aperture droop factor ~ sinc(fm*tau))')
disp('Droop at end of first pulse = ' + string(droop1) + ' V')
disp('Flat-top PAM differs from natural PAM by the aperture effect:')
disp('wide pulses / high fm -> sinc(f*tau) roll-off, needs equalizer after LP filter')
disp('Natural PAM has NO such distortion - prefer it when available.')
