// =============================================================
// Program 06.8 - PPM Demodulation
// Experiment 6: Pulse Modulation
// Objective: Recover m(t) from a PPM waveform by TIMING each pulse:
//            find the rising edge in every period, measure its delay
//            d_k = t_edge - t_s(k), invert the law m = d*mmax/D,
//            build a stair estimate, then smooth it with a short
//            moving average. Compare with the original message.
// =============================================================
// WHY edge timing works: the pulse position (not its height or width)
// carries the information, so the receiver only needs a comparator and
// a counter. This is why PPM has the best noise immunity of the three.
// Quantization: the edge can only be located to the nearest grid point,
// giving timing error <= 1/fs = 50 us -> amplitude error <= 50e-6/0.008
// * peak ~ 0.6% of peak. Negligible here.

// ---------------- PARAMETERS ----------------
fs   = 20000;                // analysis sampling frequency, Hz
Tdur = 0.1;                  // window duration, s
t    = 0:1/fs:Tdur - 1/fs;   // time vector
fm   = 5;                    // message frequency, Hz
m    = sin(2*%pi*fm*t);      // message signal m(t)
mmax = max(abs(m));
fs_s = 50;                   // pulse repetition rate, Hz
Ts   = 1/fs_s;               // sampling period, s
tau_p = 0.001;               // FIXED pulse width, s
D    = 0.008;                // max position deviation, s
A    = 1;                    // FIXED pulse amplitude, V
t_s  = 0:Ts:max(t);          // sampling instants
N    = length(t);
nper = length(t_s);          // number of periods (samples)
// --------------------------------------------

// ---- Rebuild the same PPM waveform (self-contained script)
y = zeros(1, N);
for k = 1:nper
    i_samp = round(t_s(k)*fs) + 1;
    ms     = m(i_samp);
    d_k    = D * ms / mmax;
    t_start = t_s(k) + d_k;
    i1 = round(t_start*fs) + 1;
    i2 = floor((t_start+tau_p)*fs);
    for i = i1:i2
        y(i) = A;
    end
end

// ---- Edge detection: rising edge index within each period
delay_k  = zeros(1, nper);
m_stair_pts = zeros(1, nper);
for k = 1:nper
    i1 = round(t_s(k)*fs) + 1;
    i2 = min(N, round((t_s(k)+Ts)*fs));
    seg = y(i1:i2);
    idx = find(seg >= 0.5);              // indices above mid-level
    if isempty(idx)
        delay_k(k) = %nan;               // no pulse found (should not happen)
    else
        i_edge = i1 + idx(1) - 1;        // first rising-edge index
        delay_k(k) = (i_edge - 1)/fs - t_s(k);
    end
    // Invert the modulation law: d = D*m/mmax -> m = d*mmax/D
    m_stair_pts(k) = delay_k(k) * mmax / D;
end

// ---- Stair reconstruction over the whole grid ----
// WHY centered on sampling instants: a right-aligned (causal) ZOH lags
// the message by ~Ts/2 and drags the correlation down; nearest-sample
// hold places each estimate AT its sampling instant (zero delay),
// which is the honest picture of what the detector knows and when.
m_stair = zeros(1, N);
for i = 1:N
    k = round(t(i)/Ts) + 1;
    k = min(max(k, 1), nper);
    m_stair(i) = m_stair_pts(k);
end

// ---- LP smoothing: moving average over 3 pulse periods
Lsm = round(3*Ts*fs);        // 3*Ts worth of samples = 1200
y_sm = zeros(1, N);
halfL = floor(Lsm/2);
for i = 1:N
    a = max(1, i-halfL);
    b = min(N, i+halfL);
    y_sm(i) = mean(m_stair(a:b));
end
// Rescale smoothed output to message peak for fair comparison
y_sm = y_sm * mmax / max(abs(y_sm));

// ---- Errors / correlation
m_samp = m(round(t_s*fs) + 1);                  // true sample values
%err_pts   = max(abs(m_stair_pts - m_samp));   // per-sample (grid) error
mz = m - mean(m); r = y_sm - mean(y_sm);
%corr = sum(mz.*r) / sqrt(sum(mz.^2)*sum(r.^2));

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t, m_stair, 'r--', 'LineWidth', 1.5)
xlabel('t (s)'); ylabel('amplitude (V)')
title('Original message vs stair (zero-order-hold) PPM estimate')
xgrid(); legend(['m(t)', 'm_stair(t)'], 'location', 'northeast')

subplot(2,1,2)
plot(t, m, 'b-', 'LineWidth', 2)
plot(t, y_sm, 'g-', 'LineWidth', 2)
xlabel('t (s)'); ylabel('amplitude (V)')
title('Original message vs LP-smoothed PPM estimate (MA over 3 periods)')
xgrid(); legend(['m(t)', 'm_smoothed(t)'], 'location', 'northeast')

// ---------------- KEY NUMBERS ----------------
disp('Experiment 6 / ppm-demodulation - KEY NUMBERS')
disp('Detected delays (s):')
disp(delay_k)
disp('Max per-sample error |m_est - m| = ' + string(%err_pts) + ' V')
disp('Correlation(m, smoothed)         = ' + string(%corr))
disp('Delay quantization step = 1/fs = ' + string(1/fs*1e6) + ' us -> tiny amplitude error.')
disp('PPM needs only edge timing, not pulse height/width precision.')
