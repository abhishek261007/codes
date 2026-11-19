// =============================================================
// Program 02 - Modulation Index from Envelope Extrema
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Generate AM with mu = 0.7, recover the envelope with
//            a moving-average low-pass filter acting on |s(t)|,
//            find the envelope extrema and compute the MEASURED
//            modulation index mu_meas = (Amax - Amin)/(Amax + Amin).
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
mu   = 0.7;            // TRUE modulation index used to build the signal
Tdur = 0.4;            // seconds of signal
N    = round(fs * Tdur);
L    = round(fs / fc); // moving-average length ~50: passes fm=10 Hz, rejects 2*fc=400 Hz ripple
// --------------------------------------------

t   = (0:N-1) / fs;
mn  = cos(2 * %pi * fm * t);                       // |mn| <= 1 (Am normalised to 1)
s   = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t); // conventional AM

// Envelope detector chain: |s(t)| then low-pass (moving average).
// WHY: |s| = Ac*(1+mu*mn)*|cos(wc t)| = Ac*(1+mu*mn)*(2/pi - 4/pi*sum cos(2k wc t))/2...
// i.e. |cos| has DC plus harmonics at 2*fc, 4*fc, ... The moving average
// keeps the DC-like envelope ripple term and removes the 2*fc ripple.
rect = abs(s);
acc  = 0;
env  = zeros(1, N);
for n = 1:N                    // causal running-sum moving average, O(N)
    acc = acc + rect(n);
    if n > L then
        acc = acc - rect(n - L);
        env(n) = acc / L;
    else
        env(n) = acc / n;      // startup: divide by samples seen so far
    end
end
// Compensate the known DC gain of |cos(wt)|: its mean is 2/pi,
// so multiply the recovered average by pi/2 to estimate the true envelope.
env = env * %pi / 2;

// Let the start-up transient die out before measuring extrema.
n_skip = L + round(fs / fm / 4);
env_ss = env(n_skip:N);
Amax = max(env_ss);
Amin = min(env_ss);
mu_meas = (Amax - Amin) / (Amax + Amin);

scf(1);
clf(1);
plot(t, s, "r", t, env, "k--", t, -env, "k--");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("AM (mu = 0.7): rectified + moving-average envelope recovery (dashed)");
legend("s(t)", "+envelope (recovered)", "-envelope (recovered)");
xgrid();

disp("Experiment 3 / am-modulation-index - KEY RESULTS");
mprintf("mu (true)                = %f\n", mu);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("Recovered Amax           = %f V\n", Amax);
mprintf("Recovered Amin           = %f V\n", Amin);
mprintf("mu (measured)            = %f   (Amax-Amin)/(Amax+Amin)\n", mu_meas);
mprintf("Absolute error           = %f\n", abs(mu - mu_meas));
mprintf("Recovered vs original message correlation note: envelope follows\n");
mprintf("Ac*(1 + mu*cos(2*pi*fm*t)) up to a pi/2 scale factor and small LP ripple,\n");
mprintf("so it is a scaled, slightly smoothed copy of m(t) (correlation ~ 1).\n");
