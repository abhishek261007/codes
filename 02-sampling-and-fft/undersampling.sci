// =============================================================
// Program 03 - Undersampling and Aliasing
// Experiment 2: Sampling and FFT
// Objective: Sample a 40 Hz message at 50 Hz (which is below the
// Nyquist rate of 80 Hz) and show that the samples are IDENTICAL
// to those of a 10 Hz message - the 40 Hz signal aliases to
// f_alias = |fm - k*fs_s| = |40 - 50| = 10 Hz.
// =============================================================

// ---------------- PARAMETERS ----------------
fm     = 40;          // message frequency, Hz
fs_s   = 50;          // sampling frequency, Hz  (< 2*fm = 80 Hz: VIOLATION)
Am     = 1;           // message amplitude, V
fs_hi  = 4000;        // display grid, Hz
T      = 0.2;         // total simulation time, s
// --------------------------------------------

// Aliased frequency: fold fm back into [0, fs_s/2]
k_fold   = round(fm / fs_s);            // nearest integer multiple of fs_s
f_alias  = abs(fm - k_fold * fs_s);     // 10 Hz

Ts  = 1 / fs_s;
t   = 0:1/fs_hi:T;
t_s = 0:Ts:T;

m_orig  = Am * cos(2 * %pi * fm * t);       // true 40 Hz message
m_alias = Am * cos(2 * %pi * f_alias * t);  // 10 Hz sine with SAME samples

s_orig  = Am * cos(2 * %pi * fm * t_s);     // sample the 40 Hz signal
s_alias = Am * cos(2 * %pi * f_alias * t_s);// sample the 10 Hz signal

// ---------------- PLOT: original vs apparent alias ----------------
scf(1);
clf(1);
subplot(2,1,1);
plot(t, m_orig, "k");
plot(t_s, s_orig, "r+");
ylabel("Amplitude (V)");
legend("m(t) = cos(2*pi*40 t)", "samples at 50 Hz");
title("40 Hz message sampled at 50 Hz (fs_s < 2*fm)");
xgrid();
subplot(2,1,2);
plot(t, m_alias, "b");
plot(t_s, s_alias, "r+");
xlabel("Time (s)");
ylabel("Amplitude (V)");
legend("apparent 10 Hz alias", "same sample values");
title("Reconstructed signal looks like 10 Hz - the samples are identical");
xgrid();

// ---------------- KEY NUMBERS ----------------
mprintf("\n--- Undersampling: key values ---\n");
mprintf("Message frequency fm        = %.2f Hz\n", fm);
mprintf("Sampling frequency fs_s     = %.2f Hz\n", fs_s);
mprintf("Nyquist frequency fs_s/2    = %.2f Hz\n", fs_s / 2);
mprintf("Required fs >= 2*fm         = %.2f Hz  (NOT met!)\n", 2 * fm);
mprintf("Aliasing relation f_alias   = |fm - k*fs_s|\n");
mprintf("with k = %d                  -> f_alias = |%.0f - %d*%.0f| = %.2f Hz\n", ...
        k_fold, fm, k_fold, fs_s, f_alias);
mprintf("Max difference between the two sample sets = %.3e V\n", max(abs(s_orig - s_alias)));
disp("First 8 samples of the 40 Hz signal :");
disp(s_orig(1:8));
disp("First 8 samples of the 10 Hz signal :");
disp(s_alias(1:8));

// WHY IT MATTERS:
// Any fm > fs_s/2 folds back into the baseband. cos(2*pi*40*n/50)
// = cos(2*pi*n*(0.8)) = cos(2*pi*n - 2*pi*0.2*n) = cos(2*pi*0.2*n),
// which is exactly the sampling of a 10 Hz cosine. Once sampled,
// NO processing can tell the 40 Hz original from a genuine 10 Hz
// tone - information is irretrievably lost. This is why every
// real ADC is preceded by an anti-alias (low-pass) filter.
