// =============================================================
// Program 09.3 - Granular Noise ("hunting" around a constant)
// Experiment 10: Delta Modulation
// Objective: Apply fixed-step DM to a CONSTANT (DC) message with
//   a large step delta = 0.3. Show that once the reconstruction
//   reaches the message it cannot stop - it overshoots, steps
//   back, overshoots again - producing a persistent staircase
//   oscillation known as granular noise.
// =============================================================
// WHY the oscillation happens: for a constant x(t) = 0.3 the error
//   signal is e = 0.3 - xhat. The encoder always steps toward the
//   message, but each step is a FULL delta = 0.3, far bigger than
//   the gap that remains. xhat jumps past 0.3, the sign of e flips,
//   it jumps back, and the cycle repeats forever. The staircase can
//   never settle because the quantum delta is coarse relative to the
//   signal being tracked.
// WHY this matters: slope overload pushes delta UP, granular noise
//   pushes delta DOWN - with one fixed delta you cannot win both.
//   This exact conflict is what ADAPTIVE delta modulation solves
//   (see adaptive-delta-modulation.sci). Granular noise lives on
//   QUIET segments; slope overload lives on STEEP segments.
// NOTE: an output low-pass filter can soften this ripple for display,
//   but it cannot remove the information loss - it only hides it.
// =============================================================

// ---------------- PARAMETERS ----------------
fs_s  = 100;               // sampling frequency, Hz
Am    = 0.3;               // constant message level (DC)
delta = 0.3;               // LARGE step -> granular noise on quiet signal
t     = 0:1/fs_s:1-1/fs_s; // 1 second, 100 samples
N     = length(t);
// ----------------------------------------------

x = Am*ones(1, N);         // constant message x(t) = 0.3

bits = zeros(1, N);
xhat = zeros(1, N);

// ---------- ENCODER + DECODER (same loop) ----------
xp = 0;
for n = 1:N
    if x(n) >= xp then
        e = +delta; bits(n) = 1;
    else
        e = -delta; bits(n) = 0;
    end
    xp      = xp + e;
    xhat(n) = xp;
end

err = x - xhat;
mse = mean(err.^2);

// Oscillation amplitude: peak-to-peak swing of xhat in steady state.
// After the first couple of approach steps the staircase hunts between
// two adjacent levels; measure the swing over the last 50 samples.
ss       = xhat(51:N);
osc_pp   = max(ss) - min(ss);   // peak-to-peak granular hunting amplitude

// ---------------- RESULTS ----------------
mprintf('Granular Noise (hunting around a DC level)\n');
mprintf('------------------------------------------\n');
mprintf('Message x(t) = %.2f (constant), delta = %.2f, fs_s = %d Hz\n', Am, delta, fs_s);
mprintf('Bits transmitted = %d (1 bit per sample)\n', N);
mprintf('Mean squared error      = %.6f\n', mse);
mprintf('Steady-state hunt amplitude (peak-to-peak) = %.4f  (~= delta = %.2f)\n', osc_pp, delta);
mprintf('The staircase never settles: it overshoots 0.3, steps back, overshoots...\n');
mprintf('Fix: reduce delta (but then slope overload returns) OR adapt delta per sample (ADM).\n');

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,1,1);
plot(t, x, 'b-', 'LineWidth', 2);
plot(t, xhat, 'r--', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Amplitude');
title('Granular noise: constant 0.3 vs DM staircase (delta = 0.3)');
legend(['x(t) = 0.3 (constant)', 'xhat(t) - hunts around the level'], 'in_lower_right');
xgrid();

subplot(2,1,2);
plot(t, err, 'm-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Error e(t) = x(t) - xhat(t)');
title('Granular-noise error: persistent finite ripple (does NOT decay)');
xgrid();
