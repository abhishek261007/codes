// signal-multiplication.sci
// Experiment: Signal Generation
// Objective:
//   Multiply a 5 Hz message by a 50 Hz carrier. This is a preview of
//   Amplitude Modulation (AM). The key identity is:
//       cos(a)*cos(b) = 0.5*[cos(a-b) + cos(a+b)]
//   so multiplication creates NEW frequencies at fc - fm and fc + fm
//   (sum and difference). A spectrum plot (FFT) proves it.

// ---------------- PARAMETERS (with units) ----------------
Am = 1;       // Amplitude of the message signal, in volts (V)
fm = 5;       // Message frequency, in hertz (Hz)
Ac = 1;       // Amplitude of the carrier signal, in volts (V)
fc = 50;      // Carrier frequency, in hertz (Hz)
fs = 1000;    // Sampling frequency (samples per second, Hz). fs >= 20*fc = 1000 Hz.
dur = 1.0;    // Duration, in seconds (s). Contains 5 message cycles and 50 carrier cycles, and gives 1 Hz FFT bin resolution.

// ---------------- TIME VECTOR ----------------
t = 0:1/fs:dur - 1/fs;   // N = fs*dur = 1000 samples
N = length(t);

// ---------------- SIGNALS ----------------
m = Am * cos(2 * %pi * fm * t);     // message (modulating signal)
c = Ac * cos(2 * %pi * fc * t);     // carrier

// Product MUST use element-wise multiplication (.*), not matrix *
p = m .* c;

// ---------------- FFT (side calculation) ----------------
// Magnitude spectrum of the product. Only the positive half is shown
// because the spectrum of a real signal is symmetric.
P = abs(fft(p)) / N;                // normalize so peak heights are comparable
half = floor(N/2);
freqs = (0:half) * fs / N;          // frequency axis in Hz
P_half = 2 * P(1:half+1);           // double one-sided amplitudes (except DC, fine for teaching)

// ---------------- FIND PEAK FREQUENCIES ----------------
// Search for local maxima above a small threshold in the positive spectrum.
threshold = 0.1 * max(P_half);
peak_freqs = [];
for k = 2:length(P_half)-1
    if P_half(k) > threshold & P_half(k) >= P_half(k-1) & P_half(k) >= P_half(k+1) then
        peak_freqs = [peak_freqs, freqs(k)];
    end
end

// ---------------- PLOTTING ----------------
scf(0); clf(0);
subplot(3, 1, 1);
plot(t, m, 'b-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('m(t) (V)');
title('Message: m(t) = cos(2*pi*5*t)');
xgrid();

subplot(3, 1, 2);
plot(t, p, 'r-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('p(t) (V)');
title('Product: p(t) = m(t) .* c(t)  (AM preview)');
xgrid();

subplot(3, 1, 3);
plot(freqs, P_half, 'k-', 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude (V)');
title('Magnitude spectrum of p(t) - peaks at fc-fm and fc+fm');
xgrid();

// ---------------- RESULTS ----------------
mprintf('\n==== Signal Multiplication Results ====\n');
mprintf('Message: Am = %.2f V, fm = %.1f Hz\n', Am, fm);
mprintf('Carrier: Ac = %.2f V, fc = %.1f Hz\n', Ac, fc);
mprintf('Expected sum/difference frequencies: fc-fm = %.1f Hz, fc+fm = %.1f Hz\n', fc - fm, fc + fm);
if length(peak_freqs) > 0 then
    mprintf('Peak frequencies found via FFT: ');
    for k = 1:length(peak_freqs)
        mprintf('%.1f Hz  ', peak_freqs(k));
    end
    mprintf('\n');
else
    mprintf('No peaks found above threshold.\n');
end
mprintf('Note: cos(a)*cos(b) = 0.5*cos(a-b) + 0.5*cos(a+b); no carrier term remains for a pure cosine message.\n');
mprintf('Each spectral line has amplitude Am*Ac/2 = %.2f V\n', Am*Ac/2);
