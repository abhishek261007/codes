// =============================================================
// Program 01 - Conventional AM (DSB-LC) Generation
// Experiment 3: DSB-SC and DSB-C AM
// Objective: Generate a conventional (full-carrier) AM signal
//            s(t) = Ac*(1 + mu*m_n(t))*cos(2*%pi*fc*t) with
//            mu = 0.5 and observe the message, carrier and the
//            amplitude-modulated waveform plus its envelope.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz  (fs >> 2*fc, required)
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz   (time plots show beat of fm on fc)
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
mu   = 0.5;            // modulation index (mu <= 1 -> envelope never crosses zero)
Tdur = 0.4;            // 0.4 s window -> 4 full message cycles at fm = 10 Hz
N    = round(fs * Tdur);
// --------------------------------------------

t  = (0:N-1) / fs;
mn = Am * cos(2 * %pi * fm * t) / Am;   // normalised message, |mn| <= 1
m  = Am * cos(2 * %pi * fm * t);        // message m(t) = Am*cos(2*pi*fm*t)
c  = Ac * cos(2 * %pi * fc * t);        // carrier alone
s  = Ac * (1 + mu * mn) .* cos(2 * %pi * fc * t);   // conventional AM
env_pos =  Ac * (1 + mu * mn);          // upper envelope (must stay >= 0)
env_neg = -Ac * (1 + mu * mn);          // lower envelope

// WHY: the factor (1 + mu*mn) is the envelope. Because mu <= 1 it never
// goes negative, so the carrier amplitude truly "follows" the message and
// a simple envelope detector can recover it.

scf(1);
clf(1);
subplot(3,1,1);
plot(t, m, "b", t, 0.35 * cos(2 * %pi * fc * t), "c--");  // carrier faint (scaled down)
ylabel("Amplitude (V)");
title("Message m(t) = Am cos(2*pi*fm*t), fm = 10 Hz  (carrier shown faint, scaled)");
legend("message m(t)", "carrier (scaled x0.35)");
xgrid();
subplot(3,1,2);
plot(t, s, "r");
ylabel("Amplitude (V)");
title("Conventional AM signal s(t) = Ac*(1 + mu*mn)*cos(2*pi*fc*t), mu = 0.5");
xgrid();
subplot(3,1,3);
plot(t, s, "r", t, env_pos, "k--", t, env_neg, "k--");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("AM signal with envelope +/- Ac*(1 + mu*cos) overlaid (dashed)");
legend("s(t)", "+envelope", "-envelope");
xgrid();

// ---------------- KEY RESULTS ----------------
Amax = max(env_pos);   // peak envelope  = Ac*(1 + mu)
Amin = min(env_pos);   // trough envelope = Ac*(1 - mu)
mu_check = (Amax - Amin) / (Amax + Amin);   // mu measured from envelope extrema
disp("Experiment 3 / am-generation - KEY RESULTS");
mprintf("mu (set)                 = %f\n", mu);
mprintf("Carrier amplitude Ac     = %f V\n", Ac);
mprintf("Envelope max Amax        = %f V  (expected Ac*(1+mu) = %f)\n", Amax, Ac*(1+mu));
mprintf("Envelope min Amin        = %f V  (expected Ac*(1-mu) = %f)\n", Amin, Ac*(1-mu));
mprintf("mu from extrema formula  = %f  (Amax-Amin)/(Amax+Amin)\n", mu_check);
mprintf("Note: envelope >= 0 because mu = %f <= 1, so envelope detection will work.\n", mu);
