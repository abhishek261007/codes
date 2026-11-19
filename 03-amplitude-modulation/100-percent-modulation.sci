// =============================================================
// Program 04 - 100% Modulation (mu = 1.0)
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Show that at mu = 1 the envelope just touches zero at
//            the message troughs. The envelope detector is now
//            MARGINAL: any noise can push the envelope negative,
//            and diagonal clipping begins.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
mu   = 1.0;            // 100% modulation: envelope dips to exactly zero
Tdur = 0.4;            // seconds
N    = round(fs * Tdur);
L    = round(fs / fc); // moving-average LP length (~50)
// --------------------------------------------

t   = (0:N-1) / fs;
mn  = cos(2 * %pi * fm * t);
m   = Am * cos(2 * %pi * fm * t);
s   = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t);
env_true = Ac * (1 + mu * mn);          // touches zero at troughs

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
env = env * %pi / 2;

scf(1);
clf(1);
subplot(2,1,1);
plot(t, s, "r", t, env_true, "k--", t, -env_true, "k--");
ylabel("Amplitude (V)");
title("100% modulated AM, mu = 1.0: envelope just touches zero");
legend("s(t)", "+envelope (true)", "-envelope (true)");
xgrid();
subplot(2,1,2);
plot(t, env, "k", t, env_true, "g--");
xlabel("Time (s)");
ylabel("Envelope (V)");
title("Recovered envelope vs true envelope: marginal, ripple at troughs");
legend("recovered", "true Ac*(1+mu*cos)");
xgrid();

disp("Experiment 3 / 100-percent-modulation - KEY RESULTS");
mprintf("mu                       = %f  (100%% modulation)\n", mu);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("Envelope min (theory)    = %f V  (= Ac*(1-mu) = 0 exactly)\n", Ac*(1-mu));
mprintf("Min of |cos| sampling    = %e  (envelope expression touches 0)\n", min(env_true));
mprintf("Envelope detection       = MARGINAL. Works on noiseless signal;\n");
mprintf("any noise/interference near the nulls causes distortion (diagonal clipping).\n");
mprintf("Practical AM transmitters keep mu <= 1, typically 0.5 to 0.8.\n");
