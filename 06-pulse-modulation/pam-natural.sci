// =============================================================
// Program 06.2 - Natural-Sampling PAM
// Experiment 6: Pulse Modulation
// Objective: Build PAM by NATURAL sampling - the top of each pulse
//            follows the message waveform instead of being flat.
//            Overlay it on the flat-top (sample-and-hold) PAM to see
//            the difference, and compare against ideal PAM.
// =============================================================
// WHY natural sampling matters: in natural sampling the pulse top is
// a slice of m(t) itself (e.g. a chopper-modulated carrier). Its
// spectrum is a replica of M(f) shaped by a sinc envelope, but it
// suffers NO aperture (droop) distortion, unlike flat-top PAM,
// because no flat holding interval is introduced. Flat-top PAM
// multiplies the spectrum by the sinc of the pulse width
// (aperture distortion) which must be equalized after detection.

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

y_nat = zeros(1, N);         // natural-sampling PAM output
y_flat = zeros(1, N);        // flat-top PAM, computed inline for comparison
for k = 1:length(t_s)
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);      // instantaneous sample value
    // Integer index range of t inside [t_s(k), t_s(k)+tau)
    i1 = round(t_s(k)*fs) + 1;
    i2 = floor((t_s(k)+tau)*fs);
    for i = i1:i2
        y_nat(i)  = m(i);    // NATURAL: pulse top follows the message
        y_flat(i) = ms;      // FLAT-TOP: pulse held at sample value
    end
end
m_samp = m(round(t_s*fs) + 1);

// Peak deviation between natural and flat-top within the pulses
dev = y_nat - y_flat;
peak_dev = max(abs(dev));

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t_s, m_samp, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r')
xlabel('t (s)'); ylabel('m(t) (V)')
title('Message m(t) with sampling instants (fs_s = 50 Hz)')
xgrid(); legend(['m(t)', 'samples'], 'location', 'northeast')

subplot(2,1,2)
plot(t, y_nat, 'r-', 'LineWidth', 2)
plot(t, y_flat, 'g--', 'LineWidth', 2)
xlabel('t (s)'); ylabel('y(t) (V)')
title('Natural PAM (red, top follows m(t)) vs flat-top PAM (green dashed)')
xgrid(); legend(['natural PAM', 'flat-top PAM'], 'location', 'northeast')

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / pam-natural - KEY NUMBERS')
disp('Number of samples: ' + string(length(t_s)))
disp('Peak |natural - flat-top| deviation inside pulses = ' + string(peak_dev) + ' V')
disp('Natural sampling: spectrum = sinc-shaped envelope, NO aperture distortion')
disp('Flat-top sampling: aperture effect (sinc roll-off of tau) needs equalization')
