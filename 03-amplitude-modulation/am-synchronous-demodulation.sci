// =============================================================
// Program 09 - Synchronous (Coherent) Demodulation
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Multiply s(t) by a locally generated carrier
//            cos(2*pi*fc*t + phi) with phi = 0, low-pass filter the
//            product, and recover m(t). Works for ANY mu, including
//            mu = 1.5 (over-modulation) where the envelope detector
//            fails. This is THE method for DSB-SC and over-modulated AM.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
Tdur = 0.4;            // seconds
N    = round(fs * Tdur);
L    = round(fs / fc); // moving-average LP length = 50 (passes fm, rejects 2*fc)
mu_normal = 0.5;       // normal modulation
mu_over   = 1.5;       // over-modulation stress test
// --------------------------------------------

t  = (0:N-1) / fs;
mn = cos(2 * %pi * fm * t);
m  = Am * mn;

function y = movavg(x, L)
    // Causal running-sum moving average (low-pass). O(N), no toolboxes.
    nx  = length(x);
    y   = zeros(1, nx);
    acc = 0;
    for k = 1:nx
        acc = acc + x(k);
        if k > L then
            acc = acc - x(k - L);
            y(k) = acc / L;
        else
            y(k) = acc / k;
        end
    end
endfunction

// ----- Case 1: mu = 0.5 (ordinary AM) -----
s1   = Ac * (1 + mu_normal * mn) .* cos(2 * %pi * fc * t);
v1   = s1 .* cos(2 * %pi * fc * t);   // mix with local carrier, phi = 0
y1   = movavg(v1, L);                 // remove 2*fc components and harmonics
y1dc = y1 - mean(y1);                 // block the Ac/2 DC term -> pure message term

// ----- Case 2: mu = 1.5 (OVER-MODULATED AM) -----
s2   = Ac * (1 + mu_over * mn) .* cos(2 * %pi * fc * t);
v2   = s2 .* cos(2 * %pi * fc * t);
y2   = movavg(v2, L);
y2dc = y2 - mean(y2);

// Theory: s*cos(wc t) = Ac*(1+mu*mn)*cos^2 = Ac/2*(1+mu*mn) + Ac/2*(1+mu*mn)*cos(2wc t)
//         LP keeps Ac/2 + (mu*Ac/2)*mn.  After DC removal: (mu*Ac/2)*mn.
//         Peak of recovered AC term = mu*Ac*Am/2.

scf(1);
clf(1);
subplot(2,1,1);
plot(t, m, "b", t, y1dc / max(abs(y1dc)), "k--");
ylabel("normalised amplitude");
title("mu = 0.5: original m(t) (solid) vs synchronous-recovered (dashed, normalised)");
legend("m(t)", "recovered, normalised");
xgrid();
subplot(2,1,2);
plot(t, m, "b", t, y2dc / max(abs(y2dc)), "k--");
xlabel("Time (s)");
ylabel("normalised amplitude");
title("mu = 1.5 (OVER-modulated): synchronous demod STILL recovers m(t) faithfully");
legend("m(t)", "recovered, normalised");
xgrid();

n_skip = L + round(fs / fm / 4);
c1 = sum(mn(n_skip:N) .* y1dc(n_skip:N)) / sqrt(sum(mn(n_skip:N).^2) * sum(y1dc(n_skip:N).^2));
c2 = sum(mn(n_skip:N) .* y2dc(n_skip:N)) / sqrt(sum(mn(n_skip:N).^2) * sum(y2dc(n_skip:N).^2));
peak1 = max(abs(y1dc(n_skip:N)));   // steady-state peak, start-up excluded
peak2 = max(abs(y2dc(n_skip:N)));

disp("Experiment 3 / am-synchronous-demodulation - KEY RESULTS");
mprintf("Case 1 mu = 0.5 : recovered peak = %f V (theory mu*Ac/2*Am = %f), corr = %f\n", ...
        peak1, mu_normal*Ac/2*Am, c1);
mprintf("Case 2 mu = 1.5 : recovered peak = %f V (theory mu*Ac/2*Am = %f), corr = %f\n", ...
        peak2, mu_over*Ac/2*Am, c2);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("Both correlations ~ 1: synchronous demodulation is LINEAR, so it\n");
mprintf("recovers m(t) faithfully for ANY mu, including over-modulation.\n");
mprintf("Residual ripple at 2*fc = 400 Hz is removed by the moving-average LP.\n");
mprintf("Cost vs envelope detector: needs a locally generated, phase-locked carrier.\n");
