// =============================================================
// Program 06.6 - PWM Demodulation
// Experiment 6: Pulse Modulation
// Objective: Demodulate PWM two ways:
//   (A) Lowpass filter: centered moving average with L = fs/fs_s = 400
//       (length Ts - notch exactly at 50 Hz). DC (tau0 offset) is
//       subtracted; output is rescaled and overlaid on m(t).
//   (B) Pulse-area integration: in each period the average value of
//       the PWM equals A*tau_k/Ts; inverting the law gives m directly.
// =============================================================
// WHY subtract the mean: y_PWM averages to A*tau0/Ts*(1 + m_mod*m/mmax),
// i.e. a DC term (A*tau0/Ts) plus a term proportional to m. The DC
// carries no information - remove it. The remaining signal is rescaled
// to unit peak for a fair overlay (a real receiver knows A, tau0, Ts).
// WHY L = fs/fs_s = 400: a moving average whose length equals Ts nulls
// 50 Hz and its multiples, while passing 5 Hz almost untouched.
// L = fs/(4*fs_s) = 100 leaves heavy 50 Hz ripple (poor correlation).

// ---------------- PARAMETERS ----------------
fs   = 20000;                // analysis sampling frequency, Hz
Tdur = 0.1;                  // window duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
fm   = 5;                    // message frequency, Hz
m    = sin(2*%pi*fm*t);      // message signal m(t)
mmax = max(abs(m));
fs_s = 50;                   // pulse repetition rate, Hz
Ts   = 1/fs_s;               // sampling period, s
tau0 = 0.008;                // mid pulse width, s
m_mod = 0.8;                 // modulation depth
A    = 1;                    // constant pulse amplitude, V
t_s  = 0:Ts:max(t);          // sampling instants
N    = length(t);
nper = length(t_s);
L    = round(fs/fs_s);       // moving-average length = 400 (one Ts)
// --------------------------------------------

// ---- Rebuild the same PWM waveform (self-contained script)
y = zeros(1, N);
for k = 1:nper
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);
    tau_k  = tau0 * (1 + m_mod * ms / mmax);
    i1 = round(t_s(k)*fs) + 1;
    i2 = floor((t_s(k)+tau_k)*fs);
    for i = i1:i2
        y(i) = A;
    end
end
m_samp = m(round(t_s*fs) + 1);

// ---- (A) Centered moving-average LP (zero group delay)
y_rec = zeros(1, N);
halfL = floor(L/2);
for i = 1:N
    a = max(1, i-halfL);
    b = min(N, i+halfL);
    y_rec(i) = mean(y(a:b));
end
y_rec = y_rec - mean(y_rec);             // remove tau0 DC offset
y_rec = y_rec * mmax / max(abs(y_rec));  // rescale to message peak
mz = m - mean(m); rA = y_rec - mean(y_rec);
%corrA = sum(mz.*rA) / sqrt(sum(mz.^2)*sum(rA.^2));

// ---- (B) Pulse-area integration per period (exact inverse)
// mean of y over one period = A*tau_k/Ts  ->  tau_k = mean*Ts/A
// m_est = (tau_k - tau0)*mmax / (m_mod*tau0)
m_est = zeros(1, nper);
for k = 1:nper
    i1 = round(t_s(k)*fs) + 1;
    if k < nper
        i2 = round(t_s(k+1)*fs);
    else
        i2 = N;
    end
    tau_k_est = mean(y(i1:i2)) * Ts / A;
    m_est(k)  = (tau_k_est - tau0) * mmax / (m_mod*tau0);
end
%errB = max(abs(m_est - m_samp));
mz2 = m_samp - mean(m_samp); r2 = m_est - mean(m_est);
%corrB = sum(mz2.*r2) / sqrt(sum(mz2.^2)*sum(r2.^2));
// Stair (nearest-sample hold) for overlay
m_stairB = zeros(1, N);
for i = 1:N
    k = round(t(i)/Ts) + 1;
    k = min(max(k, 1), nper);
    m_stairB(i) = m_est(k);
end

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1)
plot(t, y, 'r-', 'LineWidth', 1.5)
xlabel('t (s)'); ylabel('y_PWM(t) (V)')
title('PWM waveform being demodulated (A = 1 V, constant amplitude)')
xgrid()

subplot(2,1,2)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t, y_rec, 'g--', 'LineWidth', 2)
plot(t, m_stairB, 'm:', 'LineWidth', 2)
xlabel('t (s)'); ylabel('amplitude (V)')
title('Original vs PWM-demodulated: LP filter (green) and pulse-area inverse (dots)')
xgrid(); legend(['m(t)', 'LP filtered', 'pulse-area inverse'], 'location', 'northeast')

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / pwm-demodulation - KEY NUMBERS')
disp('Moving-average length L = ' + string(L) + ' samples (= 1 Ts, 50 Hz notch)')
disp('Method A (LP filter):  correlation(m, y_rec) = ' + string(%corrA))
disp('Method B (pulse area): correlation(m, m_est) = ' + string(%corrB) + ', max per-sample error = ' + string(%errB) + ' V')
disp('Demodulated signal ~ duty cycle ~ m + tau0 offset; subtracting the mean')
disp('removes the tau0 DC term. Small L: heavy ripple; large L: message sag.')
