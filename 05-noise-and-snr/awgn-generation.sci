// =============================================================
// Program 05.1 - AWGN (Additive White Gaussian Noise) Generation
// Experiment 5: AM/FM with AWGN and SNR
// Objective: Generate white Gaussian noise with sigma = 1, plot the
//            noise waveform and its histogram versus the theoretical
//            normal pdf, and verify that measured mean ~ 0 and
//            measured variance ~ sigma^2.
// =============================================================

// ---------------- PARAMETERS ----------------
fs    = 10000;               // sampling frequency, Hz
Tdur  = 0.5;                 // signal duration, s
t     = 0:1/fs:Tdur - 1/fs;  // time vector, 0 to 0.5 s in steps of 1/fs
sigma = 1;                   // noise standard deviation (noise power Pn = sigma^2 = 1)
N     = length(t);           // number of samples (5000)
// --------------------------------------------

// WHY grand(m,n,"nor",mu,sigma): Scilab's built-in Gaussian random matrix
// generator. rand() is UNIFORM, not Gaussian - never use it for AWGN.
// White noise = flat PSD over the band; successive samples are INDEPENDENT
// (uncorrelated). The name "additive" means this noise adds directly onto
// the signal: y(t) = s(t) + n(t).
rand("seed", 123);           // fix the seed so results are reproducible
n = grand(1, N, "nor", 0, sigma);

// ---------------- PLOTS ----------------
scf(1);
clf(1);

subplot(2,1,1);
plot(t, n, "b");
xlabel("Time (s)");
ylabel("Amplitude (V)");
title("White Gaussian noise n(t), sigma = 1 (note: zero mean, samples independent)");
xgrid();

subplot(2,1,2);
// WHY histplot: overlays the empirical histogram of the noise samples with
// the theoretical normal pdf so we can SEE the samples really are Gaussian.
histplot(50, n);
// Theoretical normal pdf overlaid for comparison
xs = linspace(-4*sigma, 4*sigma, 200);
pdf_theory = (1/(sigma*sqrt(2*%pi))) * exp(-0.5 * (xs/sigma).^2);
// Scale pdf to counts so it overlays the histogram: multiply by N * bin width
bin_width = (max(n) - min(n)) / 50;
plot(xs, pdf_theory * N * bin_width, "r-", "linewidth", 2);
xlabel("Noise amplitude (V)");
ylabel("Count");
title("Histogram of n(t) with theoretical normal pdf overlay (red)");
xgrid();
legend(["Samples histogram"; "Theoretical N(0, sigma^2) pdf (scaled)"]);

// ---------------- KEY RESULTS ----------------
n_mean = mean(n);            // measured mean, should be ~ 0
n_var  = variance(n);        // measured variance, should be ~ sigma^2 = 1
n_power = mean(n.^2);        // measured noise power = mean of squares

disp("Experiment 5 / awgn-generation - KEY RESULTS");
mprintf("Number of samples N      = %d\n", N);
mprintf("Measured mean of n(t)    = %f   (expected ~ 0)\n", n_mean);
mprintf("Measured variance of n   = %f   (expected ~ sigma^2 = %f)\n", n_var, sigma^2);
mprintf("Measured noise power     = %f   (mean(n.^2) = sigma^2 for zero-mean)\n", n_power);
mprintf("Note: white noise has FLAT PSD over the band; samples are independent.\n");
