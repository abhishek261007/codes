// =============================================================
// Program 04 - Sampling Exactly at Nyquist (2*fm) vs Above
// Experiment 2: Sampling and FFT
// Objective: Sample a 5 Hz message at fs_s = 2*fm = 10 Hz (the
// bare theoretical minimum) and at fs_s = 25 Hz (comfortably
// above Nyquist), and see what the samples look like in both
// cases.
// =============================================================

// ---------------- PARAMETERS ----------------
fm     = 5;           // message frequency, Hz
Am     = 1;           // message amplitude, V
fs_nyq = 2 * fm;      // sampling exactly at Nyquist = 10 Hz
fs_hi  = 25;          // sampling above Nyquist = 25 Hz
T      = 1.0;         // total simulation time, s
fs_disp = 1000;       // fine grid for drawing the true message
// --------------------------------------------

t     = 0:1/fs_disp:T;
m     = Am * cos(2 * %pi * fm * t);

// Exactly at Nyquist: Ts = 0.1 s -> samples land at t = 0, 0.1, ...
t_n   = 0:1/fs_nyq:T;
s_n   = Am * cos(2 * %pi * fm * t_n);   // = cos(pi n) = (-1)^n

// Above Nyquist: 25 Hz sampling
t_h   = 0:1/fs_hi:T;
s_h   = Am * cos(2 * %pi * fm * t_h);

// ---------------- PLOT 1: exactly at Nyquist ----------------
scf(1);
clf(1);
plot(t, m, "k--");
plot(t_n, s_n, "r+");
plot(t_n, s_n, "r-");
xlabel("Time (s)");
ylabel("Amplitude (V)");
legend("m(t) = cos(2*pi*5 t)", "samples at fs_s = 10 Hz");
title("Sampling exactly at Nyquist (fs_s = 2*fm = 10 Hz)");
xgrid();

// ---------------- PLOT 2: above Nyquist ----------------
scf(2);
clf(2);
plot(t, m, "k--");
plot(t_h, s_h, "b+");
plot(t_h, s_h, "b-");
xlabel("Time (s)");
ylabel("Amplitude (V)");
legend("m(t) = cos(2*pi*5 t)", "samples at fs_s = 25 Hz");
title("Sampling above Nyquist (fs_s = 25 Hz = 5*fm)");
xgrid();

// ---------------- KEY NUMBERS ----------------
mprintf("\n--- Nyquist-rate sampling: key values ---\n");
mprintf("Message frequency fm        = %.2f Hz\n", fm);
mprintf("Nyquist rate 2*fm           = %.2f Hz\n", 2 * fm);
mprintf("Case A fs_s = 2*fm          = %.2f Hz (exactly at the limit)\n", fs_nyq);
mprintf("Case B fs_s = 25 Hz         = %.2f Hz (%.1fx the Nyquist rate)\n", fs_hi, fs_hi / (2 * fm));
mprintf("Samples in 1 s at 10 Hz     = %d\n", length(t_n));
mprintf("Samples in 1 s at 25 Hz     = %d\n", length(t_h));
disp("Samples at exactly 2*fm (cosines hit +/-1; a sine would read all zeros!):");
disp(s_n(1:6));
disp("First 6 samples at 25 Hz:");
disp(s_h(1:6));

// WHY IT MATTERS:
// Sampling at exactly fs_s = 2*fm is legal ONLY for an ideal
// band-limited signal with no component at exactly fm and perfect
// phase alignment. Two traps:
//  (1) PHASE AMBIGUITY: a sine fm sampled at 2*fm at the instants
//      sin(pi n) = 0 gives ALL-ZERO samples - the signal vanishes
//      completely. A cosine gives (-1)^n, which survives but carries
//      NO information about phase or amplitude sign.
//  (2) At exactly 2*fm there is no guard band: copies of the
//      spectrum touch at fs_s/2, so any real filter transition band
//      causes aliasing.
// Rule of thumb: always sample strictly ABOVE 2*fm (typical headroom
// 2.5x - 10x, or 20%+ guard band plus an anti-alias filter).
