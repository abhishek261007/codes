// =============================================================
// Program 07 - DSB-C (Full-Carrier) AM Generation
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Generate DSB-C / conventional AM s(t) = Ac*(1 + mu*mn)
//            *cos(2*pi*fc*t), and compute the ratio of carrier
//            power to sideband power. NOTE: "DSB-C" (Double Sideband
//            with Carrier) IS conventional AM (DSB-LC) - the same
//            signal under another name.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
mu   = 0.5;            // modulation index
Tdur = 0.4;            // seconds
N    = round(fs * Tdur);
L    = round(fs / fc); // moving-average LP length (~50)
// --------------------------------------------

t   = (0:N-1) / fs;
mn  = cos(2 * %pi * fm * t);
s   = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t);   // DSB-C == conventional AM
env_pos =  Ac * (1 + mu * mn);
env_neg = -Ac * (1 + mu * mn);

// Envelope detector (rectify + moving average) to show it works for mu <= 1
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
plot(t, s, "r", t, env_pos, "k--", t, env_neg, "k--", t, env, "g--");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("DSB-C / conventional AM (mu = 0.5): true envelope (black dashed), recovered (green dashed)");
legend("s(t)", "+envelope true", "-envelope true", "envelope recovered");
xgrid();

// Power bookkeeping for s(t) = Ac*cos(wc t) + (mu*Ac/2)*[cos((wc+wm)t) + cos((wc-wm)t)]
Pc        = Ac^2 / 2;            // carrier power (mean square of Ac*cos)
P_usb     = (mu * Ac / 2)^2 / 2; // upper sideband power
P_lsb     = (mu * Ac / 2)^2 / 2; // lower sideband power
P_sb      = P_usb + P_lsb;       // total sideband power = mu^2*Ac^2/4
P_total   = Pc + P_sb;
ratio_c_sb = Pc / P_sb;          // carrier / sideband power ratio
eta       = P_sb / P_total;      // transmission efficiency (useful fraction)

disp("Experiment 3 / dsb-c-generation - KEY RESULTS");
mprintf("Signal type              = DSB-C = DSB with Carrier = CONVENTIONAL AM (DSB-LC)\n");
mprintf("mu                       = %f\n", mu);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("Carrier power Pc         = %f W  (Ac^2/2)\n", Pc);
mprintf("Sideband power (each)    = %f W  (mu^2*Ac^2/8)\n", P_usb);
mprintf("Total sideband power     = %f W  (mu^2*Ac^2/4)\n", P_sb);
mprintf("Total transmitted power  = %f W  (Ac^2/2)*(1 + mu^2/2)\n", P_total);
mprintf("Carrier / sideband power = %f  (2/mu^2; carrier dominates, wasteful!)\n", ratio_c_sb);
mprintf("Transmission efficiency  = %f  (eta = mu^2/(2+mu^2) = %f)\n", eta, mu^2/(2+mu^2));
mprintf("Envelope detector works  = YES (full carrier present, mu <= 1)\n");
