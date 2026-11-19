// =============================================================
// Program 09 - Two-Sided to Single-Sided Spectrum Conversion
// Experiment 2: Sampling and FFT
// Objective: Take a cosine with a DC offset, show the raw
// two-sided |fft(x)|, then build the single-sided spectrum by
// doubling the non-DC / non-Nyquist bins (and NOT doubling DC
// or Nyquist). DC is removed before the final analysis, and its
// value is printed.
// =============================================================

// ---------------- PARAMETERS ----------------
fs       = 1000;      // sampling frequency, Hz
N        = 1000;      // samples = 1 s
f0       = 50;        // tone frequency, Hz
Am       = 1;         // cosine amplitude, V
DC_true  = 1.5;       // intentional DC offset, V
// --------------------------------------------

t = (0:N-1) / fs;
x = Am * cos(2 * %pi * f0 * t) + DC_true;

// ---------------- STEP 1: raw two-sided spectrum ----------------
// Two-sided: |X[k]|/N over the full fftshifted axis -N/2..N/2-1.
// The cosine appears TWICE (at +50 Hz and -50 Hz), the DC offset
// appears once at 0 Hz.
X2   = abs(fftshift(fft(x))) / N;
f2   = (-N/2:N/2-1) * fs / N;

// ---------------- STEP 2: subtract DC ----------------
// Real measurements always have a DC term; we remove it with the
// plain mean before spectral analysis so it does not mask low bins.
DC_meas = mean(x);
x0      = x - DC_meas;

// ---------------- STEP 3: single-sided spectrum ----------------
// f = (0:N/2)*fs/N ; A = 2*|X[k]|/N for k = 1..N/2 (0-based body),
// EXCEPT the DC bin (k=0) and the Nyquist bin (k=N/2) which are
// NOT doubled. Because the input is real, X[N-k] = conj(X[k]),
// so doubling folds the negative frequencies onto 0..fs/2.
N2  = N / 2;
X   = fft(x0);
X1  = 2 * abs(X(1:N2+1)) / N;   // doubled body
X1(1)     = abs(X(1)) / N;      // DC bin: no doubling
X1(N2+1)  = abs(X(N2+1)) / N;   // Nyquist bin: no doubling
f1  = (0:N2) * fs / N;
f1(1) = 0;                       // make 0 Hz explicit for the axis

// Full single-sided INCLUDING DC (to show the residual DC bin):
Xdc      = fft(x);
X1_full  = 2 * abs(Xdc(1:N2+1)) / N;
X1_full(1)    = abs(Xdc(1)) / N;
X1_full(N2+1) = abs(Xdc(N2+1)) / N;

// ---------------- PLOT: two subplots ----------------
scf(1);
clf(1);
subplot(2,1,1);
plot(f2, X2, "b");
xlabel("Frequency (Hz)");
ylabel("|X(f)| / N");
title("Two-Sided Magnitude of cos(2*pi*50*t) + 1.5 V DC");
xgrid();
subplot(2,1,2);
plot(f1, X1, "r");
xlabel("Frequency (Hz)");
ylabel("Single-Sided Magnitude");
title("Single-Sided Spectrum after DC removal (DC bin shown would read 0)");
xgrid();

// ---------------- KEY NUMBERS ----------------
[Amax, kmax] = max(X1);
mprintf("\n--- Single-sided conversion: key values ---\n");
mprintf("Sampling frequency fs       = %.2f Hz\n", fs);
mprintf("Nyquist frequency fs/2      = %.2f Hz\n", fs / 2);
mprintf("Frequency resolution df     = fs/N = %.2f Hz\n", fs / N);
mprintf("True DC offset              = %.4f V\n", DC_true);
mprintf("Measured DC (mean of x)     = %.4f V\n", DC_meas);
Xtmp = fft(x);
mprintf("DC bin from full fft |X[0]|/N = %.4f V\n", abs(Xtmp(1)) / N);
mprintf("Doubled bins before fix     = 2x body, DC & Nyquist kept at 1x\n");
mprintf("Peak after DC removal       = %.2f Hz, amplitude %.4f (expected %.2f)\n", f1(kmax), Amax, Am);

// WHY IT MATTERS:
// The FFT of a real N-point signal is conjugate-symmetric: half the
// energy info is duplicated. Single-sided spectra are the ECE
// convention for amplitude readings. Rules:
//   * interior bins (1 .. N/2-1): multiply |X[k]| by 2/N
//   * DC bin (k=0):               |X[0]|/N        (never double)
//   * Nyquist bin (k=N/2, even N):|X[N/2]|/N      (never double)
// Doubling DC or Nyquist is the classic error that inflates the
// 0 Hz reading and the fs/2 reading by exactly 2x.
