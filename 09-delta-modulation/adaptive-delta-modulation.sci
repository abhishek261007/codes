// =============================================================
// Program 09.4 - Adaptive Delta Modulation (Jayant / Gopal rule)
// Experiment 10: Delta Modulation
// Objective: Encode the SAME hard message that caused slope overload
//   (fm = 5 Hz, A = 1) using ADAPTIVE delta modulation. The step
//   size grows by a factor K on consecutive equal bits (signal is
//   running away -> need bigger steps) and shrinks by 1/K on
//   alternating bits (signal is quiet -> need smaller steps),
//   clamped to [delta_min, delta_max]. Compare ADM against fixed
//   DM with a small step (0.05, overloaded) AND with a large step
//   (0.35, granular-noisy on quiet parts).
// =============================================================
// WHY the Jayant rule works: two equal consecutive bits mean the
//   staircase has been climbing (or falling) in the same direction
//   twice in a row - the message slope is steeper than the staircase,
//   so multiply the step by K = 1.5. Two DIFFERENT consecutive bits
//   mean the staircase is hunting back and forth around the message -
//   divide the step by K = 1.5. Clamping to [delta_min, delta_max]
//   keeps the step sane on pathological input.
// WHY the DECODER can follow: adaptation depends ONLY on the
//   transmitted bit sequence, never on x(t). The receiver runs the
//   identical adaptation loop, so both sides step in lockstep and
//   there is zero drift.
// HYSTERESIS NOTE: delta_prev must be stored BEFORE the update so
//   that sample n uses the step decided from bits n-1, n-2 - exactly
//   what the receiver does with only the bit stream available.
// =============================================================

// ---------------- PARAMETERS ----------------
fs_s     = 100;             // sampling frequency, Hz
fm       = 5;               // message frequency, Hz (steep -> hard for DM)
Am       = 1;               // message amplitude
t        = 0:1/fs_s:1-1/fs_s;
N        = length(t);
delta0   = 0.05;            // starting step for ADM
K        = 1.5;             // Jayant adaptation factor (M = 1.5)
delta_min = 0.01;           // lower clamp
delta_max = 0.5;            // upper clamp
delta_fix = 0.05;           // fixed DM for comparison (overloaded case)
// ----------------------------------------------

x = Am*sin(2*%pi*fm*t);     // the hard message from slope-overload-distortion.sci

// ---------- ADM pass ----------
bits_a  = zeros(1, N);
xhat_a  = zeros(1, N);
delta_t = zeros(1, N);      // step-size trace (for the adaptation plot)
xp      = 0;                // running reconstruction
d       = delta0;           // current step size
b_prev  = -1;               // no previous bit at n = 1
for n = 1:N
    if x(n) >= xp then
        b = 1;              // STEP UP
    else
        b = 0;              // STEP DOWN
    end
    // The step used at sample n is the one computed from bits up to
    // sample n-1; adaptation happens AFTER the comparison, identically
    // on TX and RX (RX sees only bits, so this is drift-free).
    bits_a(n)  = b;
    delta_t(n) = d;                // step used at THIS sample (known to RX too)
    if b == 1 then
        e = +d;
    else
        e = -d;
    end
    xp         = xp + e;
    xhat_a(n)  = xp;
    // adapt for the NEXT sample, based on this bit vs the previous one
    if b_prev <> -1 then
        if b == b_prev then
            d = min(d*K, delta_max);   // same direction -> grow
        else
            d = max(d/K, delta_min);   // alternating -> shrink
        end
    end
    b_prev = b;
end
err_a = x - xhat_a;
mse_a = mean(err_a.^2);

// ---------- Fixed-DM pass (delta = 0.05) ----------
bits_f = zeros(1, N);
xhat_f = zeros(1, N);
xp     = 0;
for n = 1:N
    if x(n) >= xp then
        e = +delta_fix; bits_f(n) = 1;
    else
        e = -delta_fix; bits_f(n) = 0;
    end
    xp       = xp + e;
    xhat_f(n) = xp;
end
err_f = x - xhat_f;
mse_f = mean(err_f.^2);

// ---------------- RESULTS ----------------
mprintf('Adaptive Delta Modulation (Jayant rule, K = %.1f)\n', K);
mprintf('--------------------------------------------------\n');
mprintf('fs_s = %d Hz, fm = %d Hz, A = %d\n', fs_s, fm, Am);
mprintf('delta in [%.2f, %.2f], start delta0 = %.2f\n', delta_min, delta_max, delta0);
mprintf('Bits transmitted = %d (1 bit per sample, same rate as DM)\n', N);
mprintf('Fixed DM delta = %.2f -> MSE = %.6f  (slope overload)\n', delta_fix, mse_f);
mprintf('ADM (adaptive)        -> MSE = %.6f\n', mse_a);
mprintf('Final ADM step size at n = %d: delta = %.4f\n', N, delta_t(N));
mprintf('ADM grows the step on steep flanks and shrinks it near peaks/zero crossings quiet zones.\n');

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1);
plot(t, x, 'b-', 'LineWidth', 2);
plot(t, xhat_a, 'g--', 'LineWidth', 1.5);
plot(t, xhat_f, 'r:', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Amplitude');
title('ADM vs fixed DM on the hard signal (fm = 5 Hz, A = 1)');
legend(['message x(t)', 'ADM reconstruction', 'fixed DM (delta = 0.05)'], 'in_upper_right');
xgrid();

subplot(2,1,2);
plot(1:N, delta_t, 'm-', 'LineWidth', 1.5);
xlabel('Sample index n');
ylabel('Step size delta(n)');
title('ADM step-size adaptation trace (grows on steep flanks, shrinks on quiet parts)');
xgrid();
