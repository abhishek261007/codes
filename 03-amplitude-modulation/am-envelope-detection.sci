// =============================================================
// Program 08 - Envelope Detection of AM
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Full detector chain s(t) -> |s(t)| -> moving-average
//            low-pass (L = round(fs/fc)) -> recovered message.
//            Compare recovered vs original (normalised correlation).
//            Demonstrated at mu = 0.5 where it works.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
mu   = 0.5;            // modulation index (envelope detector needs mu <= 1)
Tdur = 0.4;            // seconds
N    = round(fs * Tdur);
L    = round(fs / fc); // moving-average LP length = 50 samples.
                       // WHY: passes fm = 10 Hz (period 1000 samples >> L),
                       // attenuates the 2*fc = 400 Hz rectification ripple.
// --------------------------------------------

t   = (0:N-1) / fs;
mn  = cos(2 * %pi * fm * t);
m   = Am * mn;
s   = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t);

// --- Detector chain ---
rect = abs(s);                 // 1) rectify
acc  = 0;
env  = zeros(1, N);
for n = 1:N                    // 2) smooth with moving average (LP)
    acc = acc + rect(n);
    if n > L then
        acc = acc - rect(n - L);
        env(n) = acc / L;
    else
        env(n) = acc / n;
    end
end
env = env * %pi / 2;           // 3) undo mean gain 2/pi of |cos| 
env_ac = env - Ac;             // 4) remove DC (= Ac) -> AC-coupled message estimate

// Compare shapes: normalise both to unit energy, correlation close to 1.
n_skip  = L + round(fs / fm / 4);   // discard start-up transient
a = mn(n_skip:N);
b = env_ac(n_skip:N);
corr_val = sum(a .* b) / sqrt(sum(a .* a) * sum(b .* b));
peak_rec = max(abs(env_ac(n_skip:N)));

scf(1);
clf(1);
subplot(2,1,1);
plot(t, s, "r");
ylabel("s(t) (V)");
title("Transmitted AM signal, mu = 0.5");
xgrid();
subplot(2,1,2);
plot(t, m, "b", t, env_ac / (mu * Ac), "k--");   // recovered scaled back to message units
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("Original message (solid) vs envelope-detected, rescaled (dashed)");
legend("m(t)", "recovered / (mu*Ac)");
xgrid();

disp("Experiment 3 / am-envelope-detection - KEY RESULTS");
mprintf("mu                       = %f  (works because mu <= 1)\n", mu);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("LP length L              = %d samples (~fs/fc = %d)\n", L, round(fs/fc));
mprintf("Normalised correlation   = %f  (1.0 = perfect shape match)\n", corr_val);
mprintf("Recovered peak           = %f V  (theory mu*Ac*Am = %f)\n", peak_rec, mu*Ac*Am);
mprintf("Note: envelope detector FAILS for mu > 1 -> the (1+mu*mn) factor\n");
mprintf("goes negative, the rectified envelope folds, and the recovered wave\n");
mprintf("is a distorted version of m(t) (see over-modulation.sci). For\n");
mprintf("mu > 1 use synchronous detection (am-synchronous-demodulation.sci).\n");
