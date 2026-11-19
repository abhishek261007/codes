// =============================================================
// Program 09.1 - Delta Modulation: GOOD case (no slope overload)
// Experiment 10: Delta Modulation
// Objective: Modulate a slowly-varying sine message with fixed-step
//   linear Delta Modulation (DM). Transmit ONE bit per sample
//   (1 = staircase steps UP, 0 = steps DOWN). Reconstruct the
//   message with the integrator at the receiver and compare it
//   against the original. Verify that when delta is chosen above
//   the slope-overload threshold, tracking is clean.
// =============================================================
// WHY delta = 0.1 works here: the message x = A*sin(2*pi*fm*t) has
//   maximum slope A*2*pi*fm = 2*pi*1 = 6.28 per second. Per sample
//   (fs_s = 100 Hz) that is 6.28/100 = 0.063. The staircase can
//   climb at most delta per sample, so we need delta >= 0.063.
//   delta = 0.1 > 0.063 -> no slope overload, only small granular
//   ripple. DM is heavily oversampled relative to Nyquist (fs >= 2*fm
//   would suffice for PCM) - oversampling is the PRICE DM pays for
//   sending only 1 bit per sample.
// WHY the reconstruction equals the encoder's xhat: the decoder is a
//   pure integrator fed with the SAME signed steps the encoder used.
//   Both sides start from the same zero initial condition, so the
//   receiver output is bit-identical to the encoder's internal xhat.
// =============================================================

// ---------------- PARAMETERS ----------------
fs_s  = 100;               // sampling (step) frequency, Hz - heavily oversampled
fm    = 1;                 // message frequency, Hz
Am    = 1;                 // message amplitude
delta = 0.1;               // fixed step size (must exceed A*2*pi*fm/fs_s = 0.063)
t     = 0:1/fs_s:1-1/fs_s; // one second of the message
N     = length(t);         // number of samples (= number of bits, 1 bit/sample)
// ----------------------------------------------

x     = Am*sin(2*%pi*fm*t);  // message

bits  = zeros(1, N);         // 1 = step up, 0 = step down
xhat  = zeros(1, N);         // encoder/decoder reconstruction (staircase)

// ============ ENCODER + DECODER (same loop) ==================
// Encoder compares x(n) with the running reconstruction xhat_prev.
// Decoder integrates the transmitted bit with the SAME rule.
estep = 0;                   // last step (kept for clarity)
xp    = 0;                   // running reconstruction, starts at 0
for n = 1:N
    if x(n) >= xp then
        e = +delta;          // message is above reconstruction -> STEP UP
        bits(n) = 1;
    else
        e = -delta;          // message is below reconstruction -> STEP DOWN
        bits(n) = 0;
    end
    xp      = xp + e;        // integrator update (encoder = decoder here)
    xhat(n) = xp;
    estep   = e;
end

err  = x - xhat;             // reconstruction error
mse  = mean(err.^2);         // mean squared error
maxe = max(abs(err));        // worst-case error

// ---------------- RESULTS ----------------
mprintf('Delta Modulation - GOOD case\n');
mprintf('-----------------------------\n');
mprintf('fs_s = %d Hz, fm = %d Hz, A = %d, delta = %.3f\n', fs_s, fm, Am, delta);
mprintf('Slope-overload limit delta >= A*2*pi*fm/fs_s = %.4f -> satisfied\n', Am*2*%pi*fm/fs_s);
mprintf('Bits transmitted = %d (1 bit per sample)\n', N);
mprintf('Max |error|      = %.4f\n', maxe);
mprintf('Mean squared err = %.6f\n', mse);
mprintf('Reconstruction tracks the message closely; residual ripple is granular noise.\n');

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1);
plot(t, x, 'b-', 'LineWidth', 2);
plot(t, xhat, 'r--', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Amplitude');
title('Delta Modulation: message vs staircase reconstruction (delta = 0.1)');
legend(['message x(t) = sin(2 pi t)', 'DM reconstruction xhat(t)'], 'in_upper_right');
xgrid();

subplot(2,1,2);
plot(t, err, 'm-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Error e(t) = x(t) - xhat(t)');
title('Reconstruction error (granular ripple)');
xgrid();
