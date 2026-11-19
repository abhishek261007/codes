// =============================================================
// Program 03 - Under-Modulation (mu = 0.3)
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Show that for mu < 1 the envelope Ac*(1+mu*mn) stays
//            strictly above zero, so the envelope detector recovers
//            the message waveform without distortion.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
mu   = 0.3;            // modulation index: under-modulation (mu < 1)
Tdur = 0.4;            // seconds
N    = round(fs * Tdur);
L    = round(fs / fc); // moving-average LP length (~50)
// --------------------------------------------

t   = (0:N-1) / fs;
mn  = cos(2 * %pi * fm * t);
m   = Am * cos(2 * %pi * fm * t);
s   = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t);

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
env = env * %pi / 2;   // undo mean gain 2/pi of full-wave rectified carrier
env_msg = env - Ac;    // subtract DC (= Ac) to expose the AC message term

scf(1);
clf(1);
subplot(3,1,1);
plot(t, m, "b");
ylabel("m(t) (V)");
title("Message m(t) = Am cos(2*pi*fm*t)");
xgrid();
subplot(3,1,2);
plot(t, s, "r");
ylabel("s(t) (V)");
title("Under-modulated AM, mu = 0.3 (envelope comfortably above zero)");
xgrid();
subplot(3,1,3);
plot(t, env_msg, "k", t, mu * Ac * mn, "g--");
xlabel("Time (s)");
ylabel("AC component (V)");
title("Recovered envelope (AC-coupled) vs true mu*Ac*cos(2*pi*fm*t)");
legend("recovered (envelope detector)", "original, scaled mu*Ac");
xgrid();

Amin_expr = Ac * (1 - mu);   // minimum of the true envelope expression
disp("Experiment 3 / under-modulation - KEY RESULTS");
mprintf("mu                       = %f  (< 1: under-modulation)\n", mu);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("Envelope min (theory)    = %f V  (= Ac*(1-mu), always > 0)\n", Amin_expr);
mprintf("Envelope max (theory)    = %f V  (= Ac*(1+mu))\n", Ac*(1+mu));
mprintf("Envelope detection       = WORKS (envelope never crosses zero)\n");
