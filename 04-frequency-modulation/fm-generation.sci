// =============================================================
// Program 04.1 - FM Signal Generation (phase-integration method)
// Experiment 4: FM Transmission and Reception
// Objective: Generate an FM signal with beta = 1 by integrating
//            the message to obtain the phase deviation, plot the
//            message, the instantaneous frequency f_i(t) and the
//            FM waveform, and disp the deviation and beta.
// =============================================================

// ---------------- PARAMETERS ----------------
fs   = 10000;          // sampling frequency, Hz  (fs >> fc, required)
fm   = 10;             // message frequency, Hz
fc   = 200;            // carrier frequency, Hz
Ac   = 1;              // carrier amplitude, V
Am   = 1;              // message amplitude, V
beta = 1;              // modulation index (moderate: several sidebands)
df   = beta * fm;      // frequency deviation, Hz  (df = beta*fm = 10 Hz)
kf   = df / Am;        // frequency sensitivity, Hz/V  (kf = df/Am)
Tdur = 0.4;            // 0.4 s window -> 4 full message cycles at fm = 10 Hz
N    = round(fs * Tdur);
// --------------------------------------------

t = (0:N-1) / fs;
m = Am * cos(2 * %pi * fm * t);           // message m(t) = Am*cos(2*pi*fm*t)

// WHY phase integration: FM is defined by  s(t) = Ac*cos(phi(t))  with
// instantaneous frequency f_i(t) = fc + kf*m(t).  Integrating f_i gives the
// phase:  phi(t) = 2*pi*fc*t + 2*pi*kf*int(m(tau))dtau.  Numerically we use
// cumsum(m)/fs as the running integral - this is the CORRECT way to make FM.
// Simply writing cos(2*pi*(fc + kf*m(t))*t) is WRONG (that is not constant-
// envelope FM and its spectrum is not Bessel-shaped).
phase = 2 * %pi * fc * t + 2 * %pi * kf * cumsum(m) / fs;
s     = Ac * cos(phase);

// Instantaneous frequency: derivative of phase / (2*pi) = fc + kf*m(t)
fc_inst = fc + kf * m;   // swings between fc - df and fc + df

scf(1);
clf(1);
subplot(3,1,1);
plot(t, m, "b");
ylabel("Amplitude (V)");
title("Message m(t) = Am cos(2*pi*fm*t), fm = 10 Hz");
xgrid();
subplot(3,1,2);
plot(t, fc_inst, "g");
ylabel("f_i(t) (Hz)");
title("Instantaneous frequency f_i(t) = fc + kf*m(t), swings +/- df around fc = 200 Hz");
xgrid();
subplot(3,1,3);
plot(t, s, "r");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("FM signal s(t) = Ac*cos(2*pi*fc*t + 2*pi*kf*integral(m)), beta = 1");
xgrid();

// ---------------- KEY RESULTS ----------------
disp("Experiment 4 / fm-generation - KEY RESULTS");
mprintf("Frequency deviation df    = %f Hz   (df = beta*fm = %f*%f)\n", df, beta, fm);
mprintf("Modulation index beta    = %f      (beta = df/fm)\n", beta);
mprintf("kf                       = %f Hz/V  (kf = df/Am)\n", kf);
mprintf("Instantaneous frequency  = fc + kf*m(t), range %f to %f Hz\n", fc-df, fc+df);
mprintf("Note: amplitude of s(t) is constant = Ac; only the zero-crossing rate changes.\n");
