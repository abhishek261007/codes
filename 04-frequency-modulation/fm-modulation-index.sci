// =============================================================
// Program 04.2 - FM Modulation Index, two ways
// Experiment 4: FM Transmission and Reception
// Objective: Set fm = 10 Hz, Ac = 1 V and choose kf so that
//            beta = 3 (df = 30 Hz). Compute beta from parameters
//            (df/fm) and from the measured instantaneous-frequency
//            swing ((fi_max - fc)/fm) and show they agree. Plot
//            the instantaneous frequency.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
beta_target = 3;       // desired modulation index
df   = beta_target * fm;   // required deviation, Hz (df = 30 Hz)
kf   = df / Am;            // frequency sensitivity, Hz/V (kf = 30 Hz/V)
Tdur = 0.4;            // 0.4 s window -> 4 full message cycles
N    = round(fs * Tdur);
// --------------------------------------------

t  = (0:N-1) / fs;
m  = Am * cos(2 * %pi * fm * t);
phase   = 2 * %pi * fc * t + 2 * %pi * kf * cumsum(m) / fs;
s       = Ac * cos(phase);

// WHY: instantaneous frequency is the derivative of total phase divided by
// 2*pi.  Here we know it analytically: f_i(t) = fc + kf*m(t).  A purely
// numerical check would differentiate the (unwrapped) phase; the analytic
// form is used for the plot and the swing measurement is taken from it.
fi   = fc + kf * m;            // instantaneous frequency, Hz
fi_max = max(fi);
fi_min = min(fi);

// Beta method 1: from parameters
beta_1 = df / fm;
// Beta method 2: from measured instantaneous-frequency swing
beta_2 = (fi_max - fc) / fm;   // peak swing above carrier, divided by fm
swing  = fi_max - fi_min;      // full peak-to-peak swing = 2*df

scf(1);
clf(1);
subplot(2,1,1);
plot(t, m, "b");
ylabel("m(t) (V)");
title("Message m(t) = Am cos(2*pi*fm*t), Am = 1 V, fm = 10 Hz");
xgrid();
subplot(2,1,2);
plot(t, fi, "g");
xlabel("Time (s)");
ylabel("f_i(t) (Hz)");
title("Instantaneous frequency f_i(t) = fc + kf*m(t): 200 +/- 30 Hz for beta = 3");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 4 / fm-modulation-index - KEY RESULTS");
mprintf("kf (chosen)                = %f Hz/V\n", kf);
mprintf("df = kf*Am                 = %f Hz\n", df);
mprintf("beta (method 1: df/fm)     = %f\n", beta_1);
mprintf("fi_max                     = %f Hz\n", fi_max);
mprintf("fi_min                     = %f Hz\n", fi_min);
mprintf("beta (method 2: (fi_max-fc)/fm) = %f\n", beta_2);
mprintf("Peak-to-peak swing         = %f Hz  (= 2*df = %f)\n", swing, 2*df);
mprintf("Difference (should be ~0)  = %e\n", abs(beta_1 - beta_2));
mprintf("Note: beta = peak phase deviation in radians = df/fm; kf has units Hz/V.\n");
