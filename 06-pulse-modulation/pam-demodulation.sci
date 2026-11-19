// =============================================================
// Program 06.4 - PAM Demodulation
// Experiment 6: Pulse Modulation
// Objective: Recover m(t) from a PAM waveform two ways:
//   (A) SINC interpolation (ideal bandlimited reconstruction)
//   (B) Lowpass filter (moving average, L = fs/fs_s = 400)
// =============================================================
// WHY two methods: (A) is the theory - a bandlimited signal is exactly
// sum_k m(kTs)*sinc((t-kTs)/Ts). (B) is the practical receiver - an LPF
// at the detector. A centered moving average has zero group delay.
// WHY L = round(fs/fs_s) = 400: a moving average whose length equals
// Ts has a transfer function sinc with a notch exactly at the pulse
// rate (50 Hz) and its multiples - the 50 Hz switching ripple is
// nulled while the 5 Hz message passes with gain sinc(fm*Ts) = 0.984.
// L = fs/(2*fs_s) = 200 leaves more ripple (correlation drops).
// WHY the duty-cycle normalization: the MA output peaks at
// A*tau/Ts = 0.25*A, so multiply by Ts/tau = 4 to match m(t)'s peak.

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
L    = round(fs/fs_s);       // moving-average length = one Ts (400 samples)
// --------------------------------------------

// ---- Build ideal PAM first (same construction as pam-generation.sci)
y = zeros(1, N);
for k = 1:length(t_s)
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);
    i1 = round(t_s(k)*fs) + 1;
    i2 = floor((t_s(k)+tau)*fs);
    for i = i1:i2
        y(i) = ms;
    end
end
m_samp = m(round(t_s*fs) + 1);

// ---- (A) SINC interpolation ----
// sinc(x) = sin(pi*x)/(pi*x); define locally so the script never
// depends on a toolbox builtin being present.
function v = msinc(x)
    v = ones(x);
    idx = abs(x) > 1e-12;
    v(idx) = sin(%pi*x(idx)) ./ (%pi*x(idx));
endfunction
m_rec = zeros(1, N);
for k = 1:length(t_s)
    m_rec = m_rec + m_samp(k) * msinc((t - t_s(k))/Ts);
end

// ---- (B) Lowpass via centered moving average ----
// WHY centered: zero group delay (no compensation needed) and edge-
// preserving (window shrinks at the borders instead of filling).
y_lp = zeros(1, N);
halfL = floor(L/2);
for i = 1:N
    a = max(1, i-halfL);
    b = min(N, i+halfL);
    y_lp(i) = mean(y(a:b));
end
y_lp = y_lp * (Ts/tau);                  // normalize for 25% duty cycle
gd   = 0;                                // zero group delay (centered)
y_lp_al = y_lp;                          // already delay-compensated

%err_sinc = max(abs(m - m_rec));
// Interior error (edges suffer from truncation - samples outside the
// window are missing, so reconstruction there is expected to be poor)
i_in = (t >= 2*Ts) & (t <= max(t_s) - 2*Ts);
%err_sinc_in = max(abs(m(i_in) - m_rec(i_in)));
%corr_lp = (sum((m - mean(m)).*(y_lp_al - mean(y_lp_al)))) / sqrt(sum((m-mean(m)).^2)*sum((y_lp_al-mean(y_lp_al)).^2));

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t, m_rec, 'r--', 'LineWidth', 2)
xlabel('t (s)'); ylabel('amplitude (V)')
title('Original message vs sinc-interpolated reconstruction')
xgrid(); legend(['m(t)', 'm_sinc(t)'], 'location', 'northeast')

subplot(2,1,2)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t, y_lp_al, 'g-', 'LineWidth', 2)
xlabel('t (s)'); ylabel('amplitude (V)')
title('Original message vs moving-average LP output (centered, L = 400)')
xgrid(); legend(['m(t)', 'y_LP(t) (delay-compensated)'], 'location', 'northeast')

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / pam-demodulation - KEY NUMBERS')
disp('L = ' + string(L) + ', centered MA -> zero group delay')
disp('Max |m - m_sinc| over full window  = ' + string(%err_sinc) + ' V')
disp('Max |m - m_sinc| on interior only  = ' + string(%err_sinc_in) + ' V')
disp('Correlation(m, LP output)          = ' + string(%corr_lp))
disp('Note: sinc reconstruction is poor at window edges (missing samples);')
disp('the moving-average LP trades delay + slight sag for a simple receiver.')
