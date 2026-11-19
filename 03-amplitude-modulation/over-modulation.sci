// =============================================================
// Program 05 - Over-Modulation (mu = 1.5)
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Show that for mu > 1 the factor (1 + mu*mn) goes
//            NEGATIVE. The carrier term flips phase, the |envelope|
//            folds back on itself, and a plain envelope detector
//            recovers a DISTORTED message. Synchronous demodulation
//            is required instead.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
mu   = 1.5;            // modulation index: OVER-modulation (mu > 1)
Tdur = 0.4;            // seconds
N    = round(fs * Tdur);
L    = round(fs / fc); // moving-average LP length (~50)
// --------------------------------------------

t   = (0:N-1) / fs;
mn  = cos(2 * %pi * fm * t);
m   = Am * cos(2 * %pi * fm * t);
s   = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t);
env_expr = Ac * (1 + mu * mn);      // signed "envelope": goes NEGATIVE here

// What a real envelope detector sees after rectification:
rect = abs(s);
acc  = 0;
env  = zeros(1, N);
for n = 1:N
    acc = acc + rect(n);
    if n > L then
        acc = acc - rect(n - L);
        env(n) = acc / L;
    else
        env(n) = acc / n;
    end
end
env = env * %pi / 2;                // undo 2/pi mean of full-wave rectified cosine
env_ac = env - mean(env);           // AC-couple to compare shapes with m(t)

scf(1);
clf(1);
subplot(3,1,1);
plot(t, env_expr, "m");
ylabel("1 + mu*mn (V)");
title("Signed envelope expression Ac*(1 + 1.5*cos): CROSSES ZERO (negative part!)");
xgrid();
subplot(3,1,2);
plot(t, s, "r");
ylabel("s(t) (V)");
title("Over-modulated AM: carrier phase reversals (180 deg jumps at nulls)");
xgrid();
subplot(3,1,3);
plot(t, m / Am, "b", t, env_ac / max(abs(env_ac)), "k--");
xlabel("Time (s)");
ylabel("normalised amplitude");
title("Envelope detector output (dashed) DISTORTS vs true message (solid)");
legend("m(t) normalised", "envelope detector output, normalised");
xgrid();

disp("Experiment 3 / over-modulation - KEY RESULTS");
mprintf("mu                       = %f  (> 1: OVER-modulation)\n", mu);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("Signed envelope min      = %f V  (= Ac*(1-mu) = -0.5; NEGATIVE)\n", Ac*(1-mu));
mprintf("min(Ac*(1+mu*mn))        = %f V  (expression verified numerically)\n", min(env_expr));
mprintf("|envelope| actually folds: min of |Ac*(1+mu*mn)| = %f V\n", min(abs(env_expr)));
mprintf("Envelope detection       = FAILS (phase reversals detected as folds,\n");
mprintf("message reconstructed with wrong amplitude near the nulls).\n");
mprintf("Over-modulated AM CANNOT be envelope-detected. Use synchronous demod.\n");
