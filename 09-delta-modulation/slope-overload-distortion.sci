// =============================================================
// Program 09.2 - Slope Overload Distortion (and its cure)
// Experiment 10: Delta Modulation
// Objective: Force slope overload by choosing fm = 5 Hz with a
//   too-small step delta = 0.05, watch the staircase fail to keep
//   up with the message, then repeat with a sufficient step
//   delta = 0.35 and show the distortion disappears.
// =============================================================
// WHY overload happens: the fastest the staircase can rise is one
//   delta per sample, i.e. a maximum slope of delta*fs_s per second.
//   The sine message has maximum slope A*2*pi*fm = 1*2*pi*5 = 31.4
//   per second, which needs delta >= 31.4/100 = 0.314.
//   With delta = 0.05 the staircase manages only 5.0 per second -
//   the message simply outruns it, the reconstruction lags and
//   collapses to a smoothed, amplitude-clipped version of x(t).
//   Raising delta to 0.35 (> 0.314) restores proper tracking.
// WHY both cases are shown: slope overload is a PARAMETER choice,
//   not a decoder fault. The cure is always delta >= max|dx/dt|/fs_s
//   (or a higher fs_s, or adaptive step size -> see file 04).
// =============================================================

// ---------------- PARAMETERS ----------------
fs_s   = 100;              // sampling frequency, Hz
fm     = 5;                // message frequency, Hz (steep!)
Am     = 1;                // message amplitude
delta1 = 0.05;             // TOO SMALL -> slope overload
delta2 = 0.35;             // SUFFICIENT (>= A*2*pi*fm/fs_s = 0.314)
t      = 0:1/fs_s:1-1/fs_s;
N      = length(t);
// ----------------------------------------------

x = Am*sin(2*%pi*fm*t);    // message

// ---------- PASS 1: delta = 0.05 (overloaded) ----------
bits1 = zeros(1, N);
xhat1 = zeros(1, N);
xp    = 0;
for n = 1:N
    if x(n) >= xp then
        e = +delta1; bits1(n) = 1;
    else
        e = -delta1; bits1(n) = 0;
    end
    xp       = xp + e;
    xhat1(n) = xp;
end
err1 = x - xhat1;
mse1 = mean(err1.^2);

// ---------- PASS 2: delta = 0.35 (sufficient) ----------
bits2 = zeros(1, N);
xhat2 = zeros(1, N);
xp    = 0;
for n = 1:N
    if x(n) >= xp then
        e = +delta2; bits2(n) = 1;
    else
        e = -delta2; bits2(n) = 0;
    end
    xp       = xp + e;
    xhat2(n) = xp;
end
err2 = x - xhat2;
mse2 = mean(err2.^2);

// ---------------- RESULTS ----------------
mprintf('Slope Overload Distortion\n');
mprintf('-------------------------\n');
mprintf('fs_s = %d Hz, fm = %d Hz, A = %d\n', fs_s, fm, Am);
mprintf('Required delta >= A*2*pi*fm/fs_s = %.4f\n', Am*2*%pi*fm/fs_s);
mprintf('delta = %.2f -> MSE = %.6f  (slope overload, reconstruction lags message)\n', delta1, mse1);
mprintf('delta = %.2f -> MSE = %.6f  (no overload, reconstruction tracks message)\n', delta2, mse2);
mprintf('Bits transmitted per pass = %d (1 bit per sample)\n', N);

// ---------------- PLOTS ----------------
scf(1); clf();
subplot(2,2,1);
plot(t, x, 'b-', 'LineWidth', 2);
plot(t, xhat1, 'r--', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Amplitude');
title('delta = 0.05: SLOPE OVERLOAD (staircase cannot keep up)');
legend(['x(t)', 'xhat(t)'], 'in_upper_right');
xgrid();

subplot(2,2,2);
plot(t, err1, 'm-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Error e(t)');
title('Error with delta = 0.05 (large, structured)');
xgrid();

subplot(2,2,3);
plot(t, x, 'b-', 'LineWidth', 2);
plot(t, xhat2, 'g--', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Amplitude');
title('delta = 0.35: slope requirement met (clean tracking)');
legend(['x(t)', 'xhat(t)'], 'in_upper_right');
xgrid();

subplot(2,2,4);
plot(t, err2, 'm-', 'LineWidth', 1.5);
xlabel('Time t (s)');
ylabel('Error e(t)');
title('Error with delta = 0.35 (small granular ripple)');
xgrid();
