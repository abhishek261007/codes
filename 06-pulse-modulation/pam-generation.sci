// =============================================================
// Program 06.1 - PAM Generation (ideal / instantaneous sampling)
// Experiment 6: Pulse Modulation
// Objective: Build an ideal (instantaneous) Pulse Amplitude Modulation
//            waveform from m(t) = sin(2*pi*5*t). Narrow flat pulses of
//            width tau are placed at the sampling instants and their
//            amplitude EQUALS the message sample value at that instant
//            (sample-and-hold is NOT used here - see pam-flat-top.sci).
// =============================================================
// NOTE: This is "ideal / instantaneous" PAM (natural pulses of zero-ish
// width would be impulses). Here we use a practical narrow pulse (tau =
// 0.005 s, 25% duty) whose amplitude is the INSTANTANEOUS sample value.
// It is NOT flat-top sample-and-hold (pam-flat-top.sci) and NOT natural
// sampling (pam-natural.sci).

// ---------------- PARAMETERS ----------------
fs   = 20000;                // analysis sampling frequency, Hz (high-res grid)
Tdur = 0.1;                  // window duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector, 0.1 s window, 2000 points
fm   = 5;                    // message frequency, Hz
m    = sin(2*%pi*fm*t);      // message signal m(t)
fs_s = 50;                   // pulse repetition (sampling) rate, Hz
Ts   = 1/fs_s;               // sampling period, 0.02 s
tau  = 0.005;                // pulse width, s (25% duty cycle of Ts)
t_s  = 0:Ts:max(t);          // sampling instants
N    = length(t);
// --------------------------------------------

// WHY build y index-by-index: it is simple and provably correct -
// every output sample is set by an explicit rule, no vector tricks.
y = zeros(1, N);             // PAM output vector
for k = 1:length(t_s)
    // Sample index on the high-res grid nearest to t_s(k)
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);      // instantaneous sample value
    // Integer index range of t inside [t_s(k), t_s(k)+tau)
    i1 = round(t_s(k)*fs) + 1;          // first index with t >= t_s(k)
    i2 = floor((t_s(k)+tau)*fs);        // last index with t <  t_s(k)+tau
    for i = i1:i2
        y(i) = ms;                      // flat pulse at sample amplitude
    end
end

m_samp = m(round(t_s*fs) + 1);          // sample values for markers

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t_s, m_samp, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r')
xlabel('t (s)'); ylabel('m(t) (V)')
title('Message m(t) = sin(2*pi*5t) with sampling instants (fs_s = 50 Hz)')
xgrid(); legend(['m(t)', 'samples'], 'location', 'northeast')

subplot(2,1,2)
plot(t, y, 'r-', 'LineWidth', 2)
xlabel('t (s)'); ylabel('y_PAM(t) (V)')
title('Ideal PAM waveform - pulse amplitude = sample value, tau = 0.005 s')
xgrid()

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / pam-generation - KEY NUMBERS')
disp('Number of samples in 0.1 s window: ' + string(length(t_s)))
disp('Sampling rate fs_s = ' + string(fs_s) + ' Hz, Ts = ' + string(Ts) + ' s')
disp('Pulse width tau = ' + string(tau) + ' s, duty cycle = ' + string(tau/Ts*100) + ' %')
disp('Sample values:')
disp(t_s')
disp(m_samp')
